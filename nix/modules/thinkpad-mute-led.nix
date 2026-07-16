{ ... }:

# The ThinkPad mute (F1) and mic-mute (F4) LEDs are bound to kernel LED
# triggers ("audio-mute" / "audio-micmute") that track hardware mute switches.
# We don't want either indicator light, so detach both from their triggers and
# blank them -- muting still works, the lights just stay off.
{
  services.udev.extraRules = ''
    SUBSYSTEM=="leds", KERNEL=="platform::micmute", ACTION=="add", ATTR{trigger}="none", ATTR{brightness}="0"
    SUBSYSTEM=="leds", KERNEL=="platform::mute", ACTION=="add", ATTR{trigger}="none", ATTR{brightness}="0"
  '';
}
