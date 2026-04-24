{ config, pkgs, ... }:

let
  libinput-1-31 = pkgs.libinput.overrideAttrs (old: {
    version = "1.31.1";
    src = pkgs.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "libinput";
      repo = "libinput";
      rev = "1.31.1";
      hash = "sha256-9Ko97vJyo4a9NUF7omqHTwzVV02sJ2EqpDIh+nPeLwk=";
    };
    patches = [ ];
    buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.lua5_4 ];
  });
in
{
  system.replaceDependencies.replacements = [
    # Replace the default output (usually the library)
    {
      original = pkgs.libinput;
      replacement = libinput-1-31;
    }
    # Replace the binary output specifically
    {
      original = pkgs.libinput.bin;
      replacement = libinput-1-31.bin;
    }
    # Just in case your system uses the 'out' or 'lib' explicitly
    {
      original = pkgs.libinput.out;
      replacement = libinput-1-31.out;
    }
  ];
}
