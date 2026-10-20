#!/usr/bin/env python3
"""Export Anki review history for a date range to a JSON file, including full
card content (fields, tags, note type) alongside per-note ratings and deck.

Talks directly to AnkiConnect (http://localhost:8765) instead of going through
higher-level tools. A collection-wide review query here is one HTTP call over
plain IDs, which avoids the timeouts seen when an MCP tool tries to do the same
thing without a deck filter. Only Anki + the AnkiConnect add-on need to be
running -- this works regardless of whether an MCP server for Anki is connected.

Usage:
    python3 export_reviews.py --start-date 2026-10-20 --output ~/anki_reviews.json
    python3 export_reviews.py --start-date 2026-10-14 --end-date 2026-10-20 --output ~/week.json
"""
import argparse
import datetime as dt
import json
import sys
import urllib.request

ANKI_CONNECT_URL = "http://localhost:8765"
EASE_LABELS = {1: "again", 2: "hard", 3: "good", 4: "easy"}


def invoke(action, **params):
    payload = json.dumps({"action": action, "version": 6, "params": params}).encode("utf-8")
    req = urllib.request.Request(ANKI_CONNECT_URL, data=payload)
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            body = json.loads(resp.read().decode("utf-8"))
    except Exception as e:
        sys.exit(
            f"Could not reach AnkiConnect at {ANKI_CONNECT_URL}: {e}\n"
            "Make sure the Anki desktop app is open and the AnkiConnect add-on is installed."
        )
    if body.get("error") is not None:
        sys.exit(f"AnkiConnect error on '{action}': {body['error']}")
    return body["result"]


def chunked(seq, size):
    for i in range(0, len(seq), size):
        yield seq[i:i + size]


def day_bounds_ms(start_date, end_date):
    """[start_date 00:00, end_date+1 00:00) in local time, as epoch ms.

    Anki's revlog timestamps are local-time-based and this mirrors how Anki's
    own stats bucket reviews into calendar days (it ignores the "next day
    starts at" hour setting, same as the review_stats tool this replaces).
    """
    start = dt.datetime.strptime(start_date, "%Y-%m-%d")
    end = dt.datetime.strptime(end_date, "%Y-%m-%d") + dt.timedelta(days=1)
    return int(start.timestamp() * 1000), int(end.timestamp() * 1000)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--start-date", default=dt.date.today().isoformat(), help="YYYY-MM-DD, default: today")
    ap.add_argument("--end-date", default=None, help="YYYY-MM-DD, default: same as --start-date")
    ap.add_argument("--output", required=True, help="Path to write the JSON export to")
    args = ap.parse_args()
    end_date = args.end_date or args.start_date
    start_ms, end_ms = day_bounds_ms(args.start_date, end_date)

    all_card_ids = invoke("findCards", query="")
    if not all_card_ids:
        sys.exit("No cards found in the collection.")

    reviews_by_card = {}
    for batch in chunked(all_card_ids, 1000):
        reviews_by_card.update(invoke("getReviewsOfCards", cards=batch))

    in_range = {}
    for card_id, revs in reviews_by_card.items():
        matched = [r for r in revs if start_ms <= r["id"] < end_ms]
        if matched:
            in_range[int(card_id)] = matched

    if not in_range:
        output = {
            "period": {"start": args.start_date, "end": end_date},
            "summary": {"total_reviews": 0, "by_deck": {}},
            "cards_reviewed": [],
        }
        with open(args.output, "w", encoding="utf-8") as f:
            json.dump(output, f, ensure_ascii=False, indent=2)
        print(f"No reviews found between {args.start_date} and {end_date}. Wrote empty export to {args.output}")
        return

    card_ids = list(in_range.keys())
    cards_info = invoke("cardsInfo", cards=card_ids)
    cards_by_id = {c["cardId"]: c for c in cards_info}

    note_ids = sorted({c["note"] for c in cards_info})
    notes_info = []
    for batch in chunked(note_ids, 100):
        notes_info.extend(invoke("notesInfo", notes=batch))
    notes_by_id = {n["noteId"]: n for n in notes_info}

    # Group by note, not card: a note can have more than one card (cloze,
    # reversed cards), and a single card can show up more than once if it was
    # re-studied within the period (e.g. failed, then passed later the same
    # day) -- both cases fold into one note entry with a chronological list
    # of ratings rather than being collapsed into a single rating.
    notes = {}
    deck_stats = {}
    for card_id, revs in in_range.items():
        card = cards_by_id[card_id]
        note_id = card["note"]
        deck = card["deckName"]
        note_meta = notes_by_id.get(note_id, {})

        note = notes.get(note_id)
        if note is None:
            note = {
                "note_id": note_id,
                "deck": deck,
                "model": card["modelName"],
                "tags": note_meta.get("tags", []),
                "fields": {k: v["value"] for k, v in note_meta.get("fields", card["fields"]).items()},
                "_events": [],
            }
            notes[note_id] = note
        elif note["deck"] != deck:
            # Rare: a note whose cards were manually split across decks.
            note["deck"] += f" (+{deck})"

        for r in revs:
            note["_events"].append((r["id"], EASE_LABELS.get(r["ease"], f"unknown:{r['ease']}")))

        stats = deck_stats.setdefault(deck, {"reviews": 0, "again": 0, "hard": 0, "good": 0, "easy": 0})
        for r in revs:
            stats["reviews"] += 1
            label = EASE_LABELS.get(r["ease"])
            if label:
                stats[label] += 1

    cards_reviewed = []
    for note in notes.values():
        events = sorted(note.pop("_events"))
        note["ratings"] = [label for _, label in events]
        cards_reviewed.append(note)
    cards_reviewed.sort(key=lambda c: (c["deck"], c["note_id"]))

    total_reviews = sum(len(r) for r in in_range.values())
    assert total_reviews == sum(s["reviews"] for s in deck_stats.values())

    by_deck_summary = {}
    for deck, s in deck_stats.items():
        retention = (s["reviews"] - s["again"]) / s["reviews"] if s["reviews"] else None
        by_deck_summary[deck] = {**s, "retention": retention}

    output = {
        "period": {"start": args.start_date, "end": end_date},
        "summary": {"total_reviews": total_reviews, "by_deck": by_deck_summary},
        "cards_reviewed": cards_reviewed,
    }
    with open(args.output, "w", encoding="utf-8") as f:
        json.dump(output, f, ensure_ascii=False, indent=2)

    print(
        f"Wrote {len(cards_reviewed)} reviewed note(s), {total_reviews} review event(s), "
        f"across {len(by_deck_summary)} deck(s) to {args.output}"
    )


if __name__ == "__main__":
    main()
