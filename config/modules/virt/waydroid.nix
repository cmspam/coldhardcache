{ lib, pkgs, ... }:

let
  waydroid_1_6_2 = pkgs.waydroid-nftables.overrideAttrs (old: rec {
    version = "1.6.2";

    src = pkgs.fetchFromGitHub {
      owner = "waydroid";
      repo = "waydroid";
      rev = version;
      hash = "sha256-idO2eFR+OZBYce5WpCpIEWgMGDuq+vW9nT9i56trt34=";
    };
  });
in
{
  networking.nftables.enable = true;

  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = waydroid_1_6_2;
}
