# Shared baseline every host imports.
{ inputs, ... }:

{
  imports = [
    ./plasma.nix
    ./brave.nix
    ./fonts.nix
  ];

}
