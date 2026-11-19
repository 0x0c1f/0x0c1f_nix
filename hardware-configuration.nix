{
  # Replace in a working copy with this machine's generated hardware module.
  # The attachment describes a different machine and is not used for the machine.
  assertions = [
    # Always false, so a build without the real hardware module stops instead of booting blind.
    {
      assertion = false;
      message = "Copy this machine's /etc/nixos/hardware-configuration.nix into the working checkout before building.";
    }
  ];
}
