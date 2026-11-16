{
  # Replaced only in the writable target checkout by scripts/prepare.sh.
  # No disk identifiers or filesystem layout have been guessed.
  assertions = [
    # Always false, so a build without the real hardware module stops instead of booting blind.
    {
      assertion = false;
      message = "Desktop hardware is not configured. Run scripts/prepare.sh on NixOS with the real hardware module; see docs/SETUP.";
    }
  ];
}
