{
  description = "NixOS: GNOME base with Flatpak applications";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  # Only one host is built; all machine details come from the imported configuration.
  outputs = { nixpkgs, ... }: {
    # No system argument: the machine's generated hardware-configuration.nix sets the platform.
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      modules = [ ./configuration.nix ];
    };
  };
}
