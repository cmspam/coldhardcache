{
  inputs,
  config,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [

    # Browser
    (brave.override {
      commandLineArgs = [
        "--disable-font-subpixel-positioning"
        "--enable-features=WebUIDarkMode"
        "--force-color-profile=srgb"
        "--enable-font-antialiasing"
      ];
    })
  ];

}
