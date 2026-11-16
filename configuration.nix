# Hardware-independent part of the desktop. The flake adds hardware and boot modules separately,
# so the same imports can also be evaluated as a container for the policy check.
{
  imports = [
    # Host settings define machine.username, which the shared modules use for the login account.
    ./hosts/desktop/settings.nix
    ./modules/base.nix
    ./modules/gnome.nix
    ./modules/flatpak.nix
  ];
}
