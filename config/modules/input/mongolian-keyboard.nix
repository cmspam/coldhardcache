# Mongolian (Cyrillic) custom keyboard layout
{ config, pkgs, ... }:

{
  services.xserver.xkb.extraLayouts.mnc = {
    description = "Mongolian (Custom)";
    languages = [ "mon" ];
    symbolsFile = pkgs.writeText "mnc-symbols" ''
      default partial alphanumeric_keys

      xkb_symbols "basic" {
          name[Group1]= "Mongolian (Custom)";

          // Number Row
          key <TLDE> { [ Cyrillic_ie,       Cyrillic_IE,        grave,          asciitilde     ] };
          key <AE01> { [ 1,                 exclam,             exclam,         exclam         ] };
          key <AE02> { [ 2,                 at,                 at,             at             ] };
          key <AE03> { [ 3,                 numbersign,         numbersign,     numbersign     ] };
          key <AE04> { [ 4,                 U20ae,              dollar,         dollar         ] };
          key <AE05> { [ 5,                 percent,            percent,        percent        ] };
          key <AE06> { [ 6,                 asciicircum,        asciicircum,    asciicircum    ] };
          key <AE07> { [ 7,                 ampersand,          ampersand,      ampersand      ] };
          key <AE08> { [ 8,                 asterisk,           asterisk,       asterisk       ] };
          key <AE09> { [ 9,                 parenleft,          parenleft,      parenleft      ] };
          key <AE10> { [ 0,                 parenright,         parenright,     parenright     ] };
          key <AE11> { [ Cyrillic_softsign, Cyrillic_SOFTSIGN,  minus,          underscore     ] };
          key <AE12> { [ Cyrillic_hardsign, Cyrillic_HARDSIGN,  equal,          plus           ] };
          key <BKSL> { [ Cyrillic_io,       Cyrillic_IO,        backslash,      bar            ] };

          // Top Row
          key <AD01> { [ Cyrillic_che,      Cyrillic_CHE,       q,              Q              ] };
          key <AD02> { [ Cyrillic_yeru,     Cyrillic_YERU,      w,              W              ] };
          key <AD03> { [ Cyrillic_e,        Cyrillic_E,         e,              E              ] };
          key <AD04> { [ Cyrillic_er,       Cyrillic_ER,        r,              R              ] };
          key <AD05> { [ Cyrillic_te,       Cyrillic_TE,        t,              T              ] };
          key <AD06> { [ Cyrillic_u,        Cyrillic_U,         y,              Y              ] };
          key <AD07> { [ Cyrillic_u_straight, Cyrillic_U_straight, u,             U              ] };
          key <AD08> { [ Cyrillic_i,        Cyrillic_I,         i,              I              ] };
          key <AD09> { [ Cyrillic_o,        Cyrillic_O,         o,              O              ] };
          key <AD10> { [ Cyrillic_pe,       Cyrillic_PE,        p,              P              ] };
          key <AD11> { [ Cyrillic_ya,       Cyrillic_YA,        bracketleft,    braceleft      ] };
          key <AD12> { [ Cyrillic_yu,       Cyrillic_YU,        bracketright,   braceright     ] };

          // Middle Row
          key <AC01> { [ Cyrillic_a,        Cyrillic_A,         a,              A              ] };
          key <AC02> { [ Cyrillic_es,       Cyrillic_ES,        s,              S              ] };
          key <AC03> { [ Cyrillic_de,       Cyrillic_DE,        d,              D              ] };
          key <AC04> { [ Cyrillic_ef,       Cyrillic_EF,        f,              F              ] };
          key <AC05> { [ Cyrillic_ghe,      Cyrillic_GHE,       g,              G              ] };
          key <AC06> { [ Cyrillic_ha,       Cyrillic_HA,        h,              H              ] };
          key <AC07> { [ Cyrillic_zhe,      Cyrillic_ZHE,       j,              J              ] };
          key <AC08> { [ Cyrillic_ka,       Cyrillic_KA,        k,              K              ] };
          key <AC09> { [ Cyrillic_el,       Cyrillic_EL,        l,              L              ] };
          key <AC10> { [ Cyrillic_shorti,   Cyrillic_SHORTI,    semicolon,      colon          ] };
          key <AC11> { [ Cyrillic_o_bar,    Cyrillic_O_BAR,     apostrophe,     quotedbl       ] };

          // Bottom Row
          key <AB01> { [ Cyrillic_ze,       Cyrillic_ZE,        z,              Z              ] };
          key <AB02> { [ Cyrillic_shcha,    Cyrillic_SHCHA,     x,              X              ] };
          key <AB03> { [ Cyrillic_tse,      Cyrillic_TSE,       c,              C              ] };
          key <AB04> { [ Cyrillic_ve,       Cyrillic_VE,        v,              V              ] };
          key <AB05> { [ Cyrillic_be,       Cyrillic_BE,        b,              B              ] };
          key <AB06> { [ Cyrillic_en,       Cyrillic_EN,        n,              N              ] };
          key <AB07> { [ Cyrillic_em,       Cyrillic_EM,        m,              M              ] };
          key <AB08> { [ comma,             less,               comma,          less           ] };
          key <AB09> { [ period,            greater,            period,         greater        ] };
          key <AB10> { [ Cyrillic_sha,      Cyrillic_SHA,       question,       slash          ] };

          key <SPCE> { [ space,             space,              space,          nobreakspace   ] };

          include "level3(ralt_switch)"
      };
    '';
  };

  # Register in evdev.xml for KDE settings
  environment.etc."X11/xkb/rules/evdev.xml".text =
    let
      originalXml = builtins.readFile "${pkgs.xkeyboard_config}/etc/X11/xkb/rules/evdev.xml";
      customLayout = ''
        <layout>
          <configItem>
            <name>mnc</name>
            <shortDescription>mn</shortDescription>
            <description>Mongolian (Custom)</description>
            <languageList>
              <iso639Id>mon</iso639Id>
            </languageList>
          </configItem>
        </layout>
      '';
    in
    builtins.replaceStrings [ "</layoutList>" ] [ "${customLayout}</layoutList>" ] originalXml;
}
