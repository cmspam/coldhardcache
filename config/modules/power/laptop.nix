# Common workstation tools and utilities
{
  inputs,
  config,
  pkgs,
  ...
}:

{
  # System packages
  environment.systemPackages = with pkgs; [
    powertop
  ];

}
