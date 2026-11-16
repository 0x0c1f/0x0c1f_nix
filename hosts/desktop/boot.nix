{
  # Preparation writes a target-specific UEFI or BIOS boot module into a copy.
  assertions = [
    # Always false: building this placeholder must stop rather than guess a boot loader.
    {
      assertion = false;
      message = "Boot mode is not configured. Select --uefi or --bios DEVICE during preparation; see docs/SETUP.";
    }
  ];
}
