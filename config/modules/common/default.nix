# Shared baseline every host imports.
{ inputs, ... }:

{
  imports = [
    ./workstation.nix
    ./shell.nix
    ../../users
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.cache.nixosModules.default
  ];

  nixpkgs.overlays = [ inputs.qemu-patched.overlays.default ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # Upstream caches baked into /etc/nix/nix.conf so they're always
    # consulted in parallel (no reliance on first-time accept-flake-config
    # prompts or trusted-settings.json).
    substituters = [
      "https://cache.nixos.org"
      "https://attic.xuyh0120.win/lantian"
      "https://jovian-experiments.cachix.org"
      "https://cmspam.cachix.org"
      "https://lanzaboote.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.garnix.io"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "jovian-experiments.cachix.org-1:TyDJIG9AdB5uEAHVAVCjXU1qKBZkCIvqj4rDRz5/sfY="
      "cmspam.cachix.org-1:Xd8Ff8s65DuMHtLf+kpSsdBB62gokpj5PQWA74NU++s="
      "lanzaboote.cachix.org-1:Nt9//zGmqkg1k5iu+B3bkj3OmHKjSw9pvf3faffLLNk="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  nixpkgs.config.allowUnfree = true;

  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  # Binary cache built and served from github:cmspam/coldhardcache.
  # A local Python proxy at 127.0.0.1:37515 translates Nix's narinfo/NAR
  # protocol to GHCR OCI calls. The public key is auto-committed to
  # public-key.txt on each publish-cache run.
  services.nixcache-proxy = {
    enable = true;
    repo = "cmspam/coldhardcache";
    publicKey = "coldhardcache-1:fZh/UDMAX398mjFdVBhc36Ttk+WypJZFNKBlW13u80k=";
    requireSignatures = true;
  };
}
