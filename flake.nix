{
  description = "NixOS: GNOME base with Flatpak applications";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # The real host: its hardware and boot modules fail with an assertion until preparation
      # replaces them in a writable checkout.
      desktop = nixpkgs.lib.nixosSystem {
        modules = [
          ./configuration.nix
          ./hosts/desktop/hardware-configuration.nix
          ./hosts/desktop/boot.nix
        ];
      };

      # This fixture checks software choices without pretending to know disks.
      smoke = nixpkgs.lib.nixosSystem {
        modules = [
          ./configuration.nix
          {
            boot.isContainer = true;
          }
        ];
      };
    in
    {
      nixosConfigurations.desktop = desktop;
      formatter.${system} = pkgs.nixfmt;

      # The check evaluates the container fixture, so it passes before any hardware is known.
      checks.${system}.configuration = import ./checks/configuration.nix {
        inherit pkgs;
        config = smoke.config;
        lib = nixpkgs.lib;
      };
    };
}
