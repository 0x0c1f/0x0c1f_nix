{ pkgs, ... }:

{
  # Evaluate hardware and shared desktop modules together so their options
  # are checked as one system rather than applied as unrelated setup steps.
  imports = [
    ./hardware-configuration.nix
    ./flatpak.nix
  ];

  # Matches the BIOS/GRUB setup previously supplied for the machine.
  # Recheck these settings if the replacement machine uses different firmware/disks.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";
  services.xserver.xkb.layout = "gb";

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.core-apps.enable = false;
  services.gnome.core-developer-tools.enable = false;
  services.gnome.games.enable = false;
  services.gnome.gnome-software.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Preserve the existing machine login instead of replacing it with another user.
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  environment.systemPackages = with pkgs;
    [
      gnome-software
      gnome-console
      nautilus
      git
      nano
    ];


  services.openssh.enable = true;
  services.openssh.openFirewall = true;

  # Manual updates. GNOME Software still provides its Updates panel.
  system.autoUpgrade.enable = false;
  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/software".download-updates = false;
    }
  ];

  # Keep the machine's compatibility baseline; do not bump it for package updates.
  system.stateVersion = "26.05";
}
