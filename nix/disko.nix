# This machine dual-boots Windows on the same NVMe drive. disko MUST be run
# in `format,mount` mode here, never `destroy,format,mount` -- destroy wipes
# the whole partition table. In format,mount mode, disko's GPT handler only
# re-creates the table if `blkid` finds none at all on the whole disk; since
# one already exists (shared with Windows), it's left alone, and disko tries
# to create each declared partition fresh, falling back to just reapplying
# type/label/GUID in place when that slot is already occupied -- which is
# how every partition below is intended to resolve, including Windows's own.
#
# Windows's four partitions (ESP, MSR, data, recovery) are declared with
# `content = null` (disko never formats/mounts them) purely so disko's
# partition-table bookkeeping lines up with the real disk; the explicit
# `uuid` on every partition pins its GPT GUID, since omitting it makes disko
# pass `--partition-guid=N:R` (randomize) to sgdisk -- which would rewrite
# Windows's partition GUIDs on every run otherwise, even in the no-op
# relabel path. The explicit `priority` on every partition is equally
# load-bearing: disko ties all partitions at the same default priority
# (1000), and partition _index (which becomes the physical partition
# number) is derived purely from priority-sort order, not attrset
# declaration order -- get this wrong and disko could apply the wrong
# type/label to the wrong physical partition. All start/end values are the
# real on-disk sector offsets (`cat /sys/class/block/nvme0n1pN/{start,size}`
# with size converted to end = start + size/512 - 1), read 2026-11-24.
#
# Before ever running this for real: test it against a disk image with an
# identical partition layout first (see this repo's QEMU VM setup), and
# always pass --dry-run before an actual `--mode format,mount` run.
{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/nvme-XPG_GAMMIX_S70_BLADE_2P152LAEG22U";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # --- Windows's partitions, untouched (content = null) ---
            windows-esp = {
              priority = 100;
              start = "2048s";
              end = "206847s";
              type = "EF00";
              label = "EFI system partition";
              uuid = "046f4521-c711-4a4d-a2ed-89b6fc3e9813";
              content = null;
            };
            windows-msr = {
              priority = 200;
              start = "206848s";
              end = "239615s";
              type = "0C01";
              label = "Microsoft reserved partition";
              uuid = "fa8fdb9c-aa91-465e-b80f-240b9c7367a0";
              content = null;
            };
            windows-data = {
              priority = 300;
              start = "239616s";
              end = "577388543s";
              type = "0700";
              label = "Basic data partition";
              uuid = "233c8c5a-e3eb-4c37-98ad-1fc21f03e91f";
              content = null;
            };
            windows-recovery = {
              priority = 400;
              start = "577388544s";
              end = "579041279s";
              type = "2700";
              label = "";
              uuid = "61a29d29-e89e-4e4f-9410-bf824514189f";
              content = null;
            };

            # --- NixOS, replacing the previous Arch install in-place ---
            root = {
              priority = 500;
              start = "579041280s";
              end = "983791615s";
              type = "8300";
              uuid = "77d8e00d-4a26-4e9c-9da2-f73e50d3a45c";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };

            # Previously Arch's swap. Not used initially (per request) --
            # left entirely unmanaged, not reformatted, not referenced in
            # swapDevices, so the 6G stays reclaimable later either way.
            unused-swap = {
              priority = 600;
              start = "983791616s";
              end = "996374527s";
              type = "8300";
              uuid = "665a7a21-8412-45b4-a002-983a16e6497d";
              content = null;
            };

            # Previously Arch's own separate /boot: GPT-typed as plain Linux
            # filesystem (8300), not EFI System, since Arch booted it via
            # GRUB + an explicit NVRAM entry rather than ESP auto-discovery.
            # Retyped to EF00 here since systemd-boot expects a properly
            # typed ESP.
            boot = {
              priority = 700;
              start = "996374528s";
              end = "998881279s";
              type = "EF00";
              uuid = "40dcd086-0cbc-4e75-acb4-160845c4bbca";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
          };
        };
      };
    };
  };
}
