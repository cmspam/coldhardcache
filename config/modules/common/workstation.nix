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
    # Development tools
    git
    gh
    nixfmt
    jq
    comma

    # Utilities
    unzip
    iperf3
    unar
    apfs-fuse
    btrfs-progs
    e2fsprogs

    # Normal linux stuff
    pciutils
    util-linux
    smartmontools

    # Browser
    (brave.override {
      commandLineArgs = [
        "--disable-font-subpixel-positioning"
        "--enable-features=WebUIDarkMode"
        "--force-color-profile=srgb"
        "--enable-font-antialiasing"
      ];
    })

    # Virtualization
    qemu
    swtpm
  ];

  # Nano editor configuration
  programs.nano.nanorc = ''
    set tabsize 2
    set tabstospaces
  '';
}
