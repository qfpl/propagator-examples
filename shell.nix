{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc865" }:

let

  drv = import ./default.nix { inherit nixpkgs compiler; };

in

  drv.env
