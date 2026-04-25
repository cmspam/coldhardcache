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
    python3

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
