# Remote administration over SSH.
{
  # The firewall stays on; only the SSH port is opened for remote administration.
  services.openssh.enable = true;
  services.openssh.openFirewall = true;
}
