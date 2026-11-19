# Register Flathub before installing the declared applications.
# Installation is additive: this service does not make unlisted apps disappear.

{ lib, pkgs, ... }:

let
  # Treat the list as additive restore intent; applications installed outside
  # this manifest must not be removed simply because they are absent here.
  flatpakApps = builtins.fromJSON (builtins.readFile ./flatpak-apps.json);
  installApp = app: ''
    if ! flatpak info --system ${lib.escapeShellArg app.appId} >/dev/null 2>&1; then
      flatpak install --system --noninteractive --assumeyes \
        ${lib.escapeShellArg app.remote} ${lib.escapeShellArg app.appId}
    fi
  '';
in
{
  services.flatpak.enable = true;

  systemd.services.flatpak-add-remote = {
    description = "Register Flathub";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      flatpak remote-add --system --if-not-exists flathub \
        https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };

  systemd.services.flatpak-install-apps = {
    description = "Install configured Flatpak applications";
    wantedBy = [ "multi-user.target" ];
    requires = [ "flatpak-add-remote.service" ];
    after = [ "flatpak-add-remote.service" ];
    path = [ pkgs.flatpak ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    # Install missing apps; do not update installed apps or remove other apps.
    script = lib.concatMapStringsSep "\n" installApp flatpakApps.apps;
  };
}
