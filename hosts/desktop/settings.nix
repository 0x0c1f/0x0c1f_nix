{ lib, ... }:
{
  # The pattern keeps the account name valid for useradd before any module uses it.
  options.machine.username = lib.mkOption {
    type = lib.types.strMatching "[a-z_][a-z0-9_-]*";
    default = "linux";
    description = "Normal login account managed by this configuration.";
  };

  # Per-machine values a writable checkout is expected to change; the shared modules stay generic.
  config = {
    machine.username = "linux";
    networking.hostName = "nixos";
    nixpkgs.hostPlatform = "x86_64-linux";
    time.timeZone = "Europe/London";
    i18n.defaultLocale = "en_GB.UTF-8";
    console.keyMap = "uk";
    services.xserver.xkb.layout = "gb";

    # Compatibility baseline, not a package-update switch. Keep this unchanged
    # during routine input updates. Existing systems must retain their own value.
    system.stateVersion = "26.05";
  };
}
