{ pkgs, ... }:
{
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Avoid the bundled browser, office/media viewers and general app suite.
  # Keep the tools that form the desktop experience in the base system.
  services.gnome.core-apps.enable = false;
  services.gnome.gnome-software.enable = true;
  environment.systemPackages = with pkgs;
    [
      gnome-console
      nautilus
      gnome-text-editor
      gnome-system-monitor
    ];

  # Default to manual Flatpak updates while keeping Software's Update button.
  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/software".download-updates = false;
    }
  ];

  # Let PipeWire satisfy PulseAudio clients instead of starting a competing
  # audio server alongside the desktop's selected audio stack.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # GNOME's NixOS module supplies the GNOME/GTK desktop portals and session
  # integration. Do not install competing portal backends or duplicate configs.
}
