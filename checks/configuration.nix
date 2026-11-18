# Return a build check for the evaluated desktop policy. These assertions
# validate configuration choices; they do not prove that a live desktop or
# SSH connection works on the target hardware.

{ config, lib, pkgs }:
let
  names = map lib.getName config.environment.systemPackages;
  assertionsPass = builtins.all (item: item.assertion) config.assertions;

  # Graphical apps must come from Flatpak, so the check also fails if Chrome, Firefox or VLC
  # slip into the system package list, and if unattended upgrades are switched on.
  policy =
    config.services.desktopManager.gnome.enable
    && config.services.displayManager.gdm.enable
    && config.services.gnome.gnome-software.enable
    && !config.services.gnome.core-apps.enable
    && config.services.pipewire.enable
    && config.xdg.portal.enable
    && config.services.flatpak.enable
    && config.networking.networkmanager.enable
    && config.networking.firewall.enable
    && !config.system.autoUpgrade.enable
    && config.nixpkgs.config.allowUnfree

    # SSH must be reachable through the firewall on port 22.
    && config.services.openssh.enable
    && config.services.openssh.openFirewall
    && builtins.elem 22 config.networking.firewall.allowedTCPPorts
    && builtins.hasAttr config.machine.username config.users.users
    && builtins.hasAttr "flatpak-flathub" config.systemd.services
    && builtins.elem "gnome-console" names
    && !(builtins.elem "google-chrome" names)
    && !(builtins.elem "firefox" names)
    && !(builtins.elem "vlc" names);
in
# Fail during evaluation with one message; the derivation itself only marks success.
assert lib.assertMsg (assertionsPass && policy) "GNOME/Flatpak base configuration policy failed";
pkgs.runCommand "gnome-flatpak-configuration-check" { } ''
  touch "$out"
''
