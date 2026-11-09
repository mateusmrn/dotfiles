# Boot into Windows on the next reboot only (sets EFI BootNext, skips F8/F9 at firmware screen)
function bootwin
  set -l entry (efibootmgr | grep -oP '(?<=^Boot)[0-9A-Fa-f]{4}(?=\* Windows Boot Manager)')
  if test -z "$entry"
    echo "Could not find a 'Windows Boot Manager' EFI boot entry." >&2
    return 1
  end
  sudo efibootmgr -n $entry
  echo "BootNext set to Windows ($entry). Run 'reboot' when ready."
end
