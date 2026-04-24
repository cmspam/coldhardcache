{
  description = "NixOS configuration for Charles's machines";

  nixConfig = {
    extra-substituters = [
      "https://attic.xuyh0120.win/lantian"
      "https://jovian-experiments.cachix.org"
      "https://cmspam.cachix.org"
      "https://lanzaboote.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "jovian-experiments.cachix.org-1:TyDJIG9AdB5uEAHVAVCjXU1qKBZkCIvqj4rDRz5/sfY="
      "cmspam.cachix.org-1:Xd8Ff8s65DuMHtLf+kpSsdBB62gokpj5PQWA74NU++s="
      "lanzaboote.cachix.org-1:Nt9//zGmqkg1k5iu+B3bkj3OmHKjSw9pvf3faffLLNk="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    hapticctl = {
      url = "github:cmspam/hapticctl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    qemu-patched = {
      url = "github:cmspam/qemu-patched/master-git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Binary-cache proxy NixOS module + package come from the companion
    # cache repo on GitHub. `pushnix` publishes this same config (sanitized)
    # as a subfolder of that repo; this `cache` input resolves to the
    # parent flake of that repo.
    cache = {
      url = "github:cmspam/coldhardcache";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-stable,
      nixos-hardware,
      jovian,
      nix-cachyos-kernel,
      hapticctl,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs-stable = import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };

      # User identity lives in private/me.nix (tracked in config/.git but
      # NEVER pushed to github — pushnix excludes the private/ directory).
      # If it's missing (e.g. someone is building from the sanitized mirror
      # on github), fall back to a generic user so evaluation still works.
      privateMe = ./private/me.nix;
      me =
        if builtins.pathExists privateMe then
          import privateMe
        else
          {
            username = "user";
            description = "User";
          };

      mkHost =
        {
          name,
          kernelOverlay,
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs pkgs-stable me;
          };
          modules = [
            ./hosts/${name}/configuration.nix
            { nixpkgs.overlays = [ kernelOverlay ]; }
          ]
          ++ extraModules;
        };
    in
    {
      nixosConfigurations.thinkbook = mkHost {
        name = "thinkbook";
        kernelOverlay = nix-cachyos-kernel.overlays.default;
        extraModules = [ hapticctl.nixosModules.default ];
      };

      nixosConfigurations.zephyrus = mkHost {
        name = "zephyrus";
        kernelOverlay = nix-cachyos-kernel.overlays.pinned;
        extraModules = [
          nixos-hardware.nixosModules.asus-zephyrus-ga402x-nvidia
          jovian.nixosModules.default
        ];
      };

      nixosConfigurations.gamepc = mkHost {
        name = "gamepc";
        kernelOverlay = nix-cachyos-kernel.overlays.pinned;
        extraModules = [ jovian.nixosModules.default ];
      };
    };
}
