# Restore recorded applications without removing unrelated installations.
# Keep user and system scope distinct because matching an app ID alone
# does not identify the installation the manifest describes.

{ pkgs, ... }:
{
  # Make the Flatpak service available independently of app choices so remote
  # registration does not have to imply installing a predefined desktop app set.
  services.flatpak.enable = true;

  # Only register the remote. Applications and updates remain user-initiated.
  systemd.services.flatpak-flathub = {
    description = "Register the system Flathub remote";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.flatpak}/bin/flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo";
    };
  };
}
