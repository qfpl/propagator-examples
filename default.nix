{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc865" }:

let

  inherit (nixpkgs) pkgs;

  f = import ./propagator-examples.nix;

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  propagators = self: pkgs.haskell.lib.dontCheck (
    self.callCabal2nix "propagators" (pkgs.fetchFromGitHub {
      owner = "gwils";
      repo = "propagators";
      rev = "8a740731e95b22217c2f32cf96c36cdfda7cbb2b";
      sha256 = "097rry8d9cky6lhicq8qv582r6wfgypwfng56jxfyfbmwd1xch9r";
    }) {});

  modifiedHaskellPackages = haskellPackages.override {
    overrides = self: super: {
      propagators = propagators self;
    };
  };

  drv = modifiedHaskellPackages.callPackage f {};

in

  drv
