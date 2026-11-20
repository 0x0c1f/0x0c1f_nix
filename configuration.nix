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
  # Kernel selection may change during updates, but loader settings must stay
  # with the installed machine so an update does not guess a new boot disk.
  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/sda";
      useOSProber = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";

  services = {
    xserver = {
      enable = true;
      xkb.layout = "gb";
    };
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    gnome = {
      core-apps.enable = false;
      core-developer-tools.enable = false;
      games.enable = false;
      gnome-software.enable = true;
    };

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };

    openssh = {
      enable = true;
      openFirewall = true;
    };
  };

  security.rtkit.enable = true;

  # Preserve the existing machine login instead of replacing it with another user.
  users.users.linux = {
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
