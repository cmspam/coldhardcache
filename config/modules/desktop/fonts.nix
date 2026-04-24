# Font configuration - Mac-like appearance with CJK support
{ config, pkgs, ... }:

{
  fonts.packages = with pkgs; [
    # Clean modern fonts
    inter
    roboto
    source-sans
    source-serif

    # Japanese fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif

    # Monospace for coding
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code

    # Emoji
    noto-fonts-color-emoji

    # Fallbacks and compatibility
    noto-fonts
    liberation_ttf
    corefonts
    vista-fonts
    google-fonts
    font-awesome
  ];

  fonts.fontconfig = {
    enable = true;
    antialias = true;

    # Mac-like font rendering
    hinting = {
      enable = true;
      style = "slight";
      autohint = false;
    };

    subpixel = {
      rgba = "rgb";
      lcdfilter = "default";
    };

    defaultFonts = {
      sansSerif = [
        "Inter"
        "DejaVu Sans"
        "Noto Sans CJK JP"
      ];
      serif = [
        "Liberation Serif"
        "DejaVu Serif"
        "Noto Serif CJK JP"
      ];
      monospace = [
        "JetBrainsMono Nerd Font"
        "DejaVu Sans Mono"
        "Noto Sans Mono CJK JP"
      ];
      emoji = [ "Noto Color Emoji" ];
    };

    # Additional tweaks for crispness
    localConf = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>
        <match target="font">
          <edit name="lcdfilter" mode="assign">
            <const>lcddefault</const>
          </edit>
        </match>
        
        <match target="font">
          <edit name="hintstyle" mode="assign">
            <const>hintslight</const>
          </edit>
        </match>
        
        <match target="font">
          <edit name="antialias" mode="assign">
            <bool>true</bool>
          </edit>
        </match>
        
        <match target="font">
          <edit name="rgba" mode="assign">
            <const>rgb</const>
          </edit>
        </match>
      </fontconfig>
    '';
  };
}
