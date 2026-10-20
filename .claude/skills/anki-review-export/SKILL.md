---
name: anki-review-export
description: Export Anki review/study history for a date or date range to a JSON file that includes full card content (fields, tags, note type) alongside each note's deck and the ratings it received, not just aggregate counts. Use this whenever the user asks to export, dump, save, or back up their Anki reviews or study session to JSON, wants a record of exactly which cards they studied today/this week/in a period, or wants to analyze or archive past review activity together with the actual question/answer content rather than bare statistics. Requires the Anki desktop app to be open with the AnkiConnect add-on installed.
---

# Anki review export

Produces one JSON file describing every note reviewed in a date range: what
deck it's in, its fields/tags/note-type, and every rating ("again" / "hard" /
"good" / "easy") it received in that window, in chronological order.

## Running it

```bash
python3 scripts/export_reviews.py --start-date 2026-10-20 --output ~/anki_reviews_2026-10-20.json
```

- `--start-date` (default: today) and `--end-date` (default: same as
  `--start-date`) are both `YYYY-MM-DD`, inclusive on both ends, and bucketed
  as local calendar days (midnight to midnight).
- `--output` is required. If the user hasn't told you where to save, ask —
  don't assume a path. A reasonable default to propose is their home
  directory with a name like `anki_reviews_<start-date>.json` (or
  `anki_reviews_<start>_to_<end>.json` for a range).

The script talks to AnkiConnect directly over HTTP (`localhost:8765`) rather
than through MCP tools. Pull the actual review log (`getReviewsOfCards`) for
every card in the collection in one shot, then filter by timestamp — that's
cheap even for large collections, since it's one query over plain IDs rather
than repeated per-deck round trips. This sidesteps a real failure mode: asking
an aggregate stats tool for review history across the *whole* collection with
no deck filter can time out against AnkiConnect, while the same query scoped
to one deck at a time succeeds — so if you ever find yourself reaching for
deck-by-deck MCP tool calls here instead, prefer fixing the single script
instead, since that's what forced per-deck chunking in the first place.

It also avoids Anki's `rated:N` search syntax (which only means "in the last N
days relative to right now" and gets ambiguous once a note was reviewed more
than once in the window — it won't tell you *which* rating came from *which*
pass), by reading exact timestamped events straight from the review log
instead. That gives exact chronological ratings per note for free, and it is
why arbitrary historical ranges (not anchored to "today") work correctly here.

If AnkiConnect isn't reachable, the script exits with a clear message —
that means Anki isn't open or the AnkiConnect add-on isn't installed; tell the
user rather than retrying blindly.

## Output shape

```json
{
  "period": { "start": "2026-10-20", "end": "2026-10-20" },
  "summary": {
    "total_reviews": 99,
    "by_deck": {
      "Carreira": { "reviews": 71, "again": 4, "hard": 2, "good": 65, "easy": 0, "retention": 0.9436619718309859 },
      "Concursos": { "reviews": 28, "again": 0, "hard": 4, "good": 24, "easy": 0, "retention": 1.0 }
    }
  },
  "cards_reviewed": [
    {
      "note_id": 1786577412734,
      "deck": "Carreira",
      "model": "Basic",
      "tags": ["isec::iso27002::nbr2022"],
      "fields": { "Front": "...", "Back": "..." },
      "ratings": ["again", "good"]
    }
  ]
}
```

`fields` holds the raw field values as stored in Anki (including any HTML).
`ratings` is a list, not a single value — most notes have exactly one entry,
but a note studied more than once in the period (e.g. failed, then re-studied
and passed the same day) gets one entry per pass, oldest first. `retention`
is `(reviews - again) / reviews`.

## After exporting

Briefly summarize what was found (totals, any deck that stands out for a high
`again` count) rather than just dropping the file path — the user is usually
checking in on how a study session went, not only archiving it.
