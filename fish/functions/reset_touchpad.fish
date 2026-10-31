# Reset Touchpad
# Re-initializes the Synaptics I2C touchpad after it wedges into single-contact
# mode (usually after an s2idle resume): pointer and tap still work, but
# two-finger scroll, multi-finger gestures and two-finger right-click are dead.
# Unbinding and rebinding hid-multitouch forces the pad to renegotiate its
# report protocol. A warm reboot does NOT fix this - the pad stays powered.
function reset_touchpad
  set -l driver /sys/bus/hid/drivers/hid-multitouch

  if not test -d $driver
    echo "reset_touchpad: hid-multitouch driver is not loaded." >&2
    return 1
  end

  # Discover the device id (06CB = Synaptics) instead of hardcoding it, since
  # the trailing instance number is not guaranteed stable across boots.
  set -l devices (command ls $driver | string match -ri '^[0-9a-f]{4}:06cb:[0-9a-f]{4}\.[0-9]+$')

  if test (count $devices) -eq 0
    echo "reset_touchpad: no Synaptics touchpad bound to hid-multitouch." >&2
    return 1
  end

  for dev in $devices
    echo "Re-initializing $dev ..."
    if not sudo sh -c "echo -n $dev > $driver/unbind; sleep 1; echo -n $dev > $driver/bind"
      echo "reset_touchpad: failed to rebind $dev." >&2
      return 1
    end
  end

  echo "Done - test a two-finger scroll."
end
