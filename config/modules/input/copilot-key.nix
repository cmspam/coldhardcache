# copilot-key.nix
#
# Remaps the Copilot key (which emits LeftMeta+LeftShift+F23) to Right Ctrl
# using the keyd daemon. Works on both X11 and Wayland.
#
# Usage:
#   1. Save this file next to your configuration.nix
#   2. Add it to your imports, e.g.:
#
#        imports = [
#          ./hardware-configuration.nix
#          ./copilot-key.nix
#        ];
#
#   3. Run: sudo nixos-rebuild switch
#
# Panic chord: if keyd ever misbehaves, hold Backspace+Escape+Enter
# simultaneously to force-terminate the daemon.

{ ... }:

{
  services.keyd = {
    enable = true;
    keyboards.default = {
      # "*" matches all keyboards. To target only your internal keyboard,
      # run `sudo keyd monitor`, press the Copilot key, and replace "*"
      # with the id shown (e.g. "0001:0001:09b4e68d").
      ids = [ "*" ];
      settings = {
        main = {
          "leftshift+leftmeta+f23" = "rightcontrol";
        };
      };
    };
  };

  # Tells libinput to treat keyd's virtual keyboard as an internal device.
  # Without this, touchpad palm rejection can break while typing.
  # See: https://github.com/rvaiya/keyd/issues/723
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Serial Keyboards]
    MatchUdevType=keyboard
    MatchName=keyd virtual keyboard
    AttrKeyboardIntegration=internal
  '';
}
