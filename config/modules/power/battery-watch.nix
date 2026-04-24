{ pkgs, ... }:

let
  battery-watch = pkgs.writeShellApplication {
    name = "battery-watch";
    runtimeInputs = with pkgs; [
      procps
      gawk
    ];
    text = ''
      interval="''${1:-1}"
      battery="''${2:-BAT0}"
      path="/sys/class/power_supply/$battery/power_now"

      if [ ! -r "$path" ]; then
        echo "Error: cannot read $path" >&2
        exit 1
      fi

      exec watch -n "$interval" "awk '{print \$1/1000000 \" W\"}' $path"
    '';
  };
in
{
  environment.systemPackages = [ battery-watch ];
}
