{
  config,
  pkgs,
  lib,
  ...
}:
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # optional, adds docker alias
  };

}
