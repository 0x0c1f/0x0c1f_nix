{ config, pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = false;

  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  users.users.${config.machine.username} = {
    isNormalUser = true;
    description = "Desktop user";
    extraGroups = [ "wheel" "networkmanager" ];

    # An existing mutable user's password is retained. A new account is locked
    # until an administrator runs passwd. No password is embedded in the source.
  };

  environment.systemPackages = with pkgs;
    [
      git
      curl
      less
      nano
      pciutils
      usbutils
    ];

  # Explicitly manual in this source.
  # Keep activation under explicit user control; installing the base desktop
  # must not also schedule unattended switches to a new system generation.
  system.autoUpgrade.enable = false;
}
