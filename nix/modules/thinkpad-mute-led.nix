{ ... }:

{
  # Removing volume and mic mute LED
  services.udev.extraRules = ''
    SUBSYSTEM=="leds", KERNEL=="platform::micmute", ACTION=="add", ATTR{trigger}="none", ATTR{brightness}="0"
    SUBSYSTEM=="leds", KERNEL=="platform::mute", ACTION=="add", ATTR{trigger}="none", ATTR{brightness}="0"
  '';
}
