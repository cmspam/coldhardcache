# Japanese input method with Fcitx5 and Mozc
{ config, pkgs, ... }:

{
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      kdePackages.fcitx5-qt
      fcitx5-gtk
    ];
    fcitx5.waylandFrontend = true;
  };
}
