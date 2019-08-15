{ mkDerivation, base, propagators, stdenv }:
mkDerivation {
  pname = "propagator-examples";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [ base ];
  executableHaskellDepends = [ base propagators ];
  doHaddock = false;
  license = stdenv.lib.licenses.bsd3;
}
