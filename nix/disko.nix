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
# relabel path.
#
# `_index` (internal, but not read-only) is set explicitly on every
# partition rather than left to disko's priority-sort-based default. This
# matters a lot here: _index becomes the literal physical partition number
# sgdisk operates on, and leaving it auto-computed means removing an entry
# (as below, where the old swap partition is gone) silently shifts every
# later partition's computed index down by one -- which would make disko
# try to operate on the wrong physical partition. Pinning it explicitly
# removes that whole failure mode.
#
# PREREQUISITE -- disko cannot merge/delete pre-existing partitions; its
# non-destroy mode can only create a partition in genuinely free space or
# relabel an existing one in place. To fold the old Arch swap partition
# into root, a one-time manual partition-table edit on the real disk is
# required BEFORE ever running install.sh/disko against this config:
#
#   sudo sgdisk --delete=6 /dev/disk/by-id/nvme-XPG_GAMMIX_S70_BLADE_2P152LAEG22U
#   sudo sgdisk --delete=5 /dev/disk/by-id/nvme-XPG_GAMMIX_S70_BLADE_2P152LAEG22U
#   sudo sgdisk --new=5:579041280:996374527 --typecode=5:8300 --change-name=5:root \
#     /dev/disk/by-id/nvme-XPG_GAMMIX_S70_BLADE_2P152LAEG22U
#   sudo partprobe /dev/disk/by-id/nvme-XPG_GAMMIX_S70_BLADE_2P152LAEG22U
#
# This destroys whatever is currently on the Arch root and swap partitions
# (expected -- a fresh NixOS install reformats root anyway) and leaves slot
# 6 permanently unused (GPT partition numbers don't need to be contiguous,
# so boot staying numbered 7 afterward is fine). Only slots 5 and 6 are
# touched; Windows's 1-4 and the current boot partition's 7 are untouched.
#
# All start/end values are the real on-disk sector offsets
# (`cat /sys/class/block/nvme0n1pN/{start,size}` with size converted to
# end = start + size/512 - 1), read 2026-11-24, before the swap/root merge.
#
# Before ever running this for real: test it (and the prerequisite sgdisk
# sequence) against a disk image with an identical partition layout first
# (see this repo's QEMU VM setup), and always pass --dry-run before an
# actual `--mode format,mount` run.
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
              _index = 1;
              start = "2048s";
              end = "206847s";
              type = "EF00";
              label = "EFI system partition";
              uuid = "046f4521-c711-4a4d-a2ed-89b6fc3e9813";
              content = null;
            };
            windows-msr = {
              _index = 2;
              start = "206848s";
              end = "239615s";
              type = "0C01";
              label = "Microsoft reserved partition";
              uuid = "fa8fdb9c-aa91-465e-b80f-240b9c7367a0";
              content = null;
            };
            windows-data = {
              _index = 3;
              start = "239616s";
              end = "577388543s";
              type = "0700";
              label = "Basic data partition";
              uuid = "233c8c5a-e3eb-4c37-98ad-1fc21f03e91f";
              content = null;
            };
            windows-recovery = {
              _index = 4;
              start = "577388544s";
              end = "579041279s";
              type = "2700";
              label = "";
              uuid = "61a29d29-e89e-4e4f-9410-bf824514189f";
              content = null;
            };

            # --- NixOS, replacing the previous Arch install in-place ---
            # Covers the old root (p5) AND the old swap (p6)'s combined
            # range -- see the PREREQUISITE comment above. No swap is
            # configured; not needed, per request.
            root = {
              _index = 5;
              start = "579041280s";
              end = "996374527s";
              type = "8300";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };

            # Previously Arch's own separate /boot: GPT-typed as plain Linux
            # filesystem (8300), not EFI System, since Arch booted it via
            # GRUB + an explicit NVRAM entry rather than ESP auto-discovery.
            # Retyped to EF00 here since systemd-boot expects a properly
            # typed ESP. Still physically partition 7 -- slot 6 (the old
            # swap) is gone, not renumbered into.
            boot = {
              _index = 7;
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
