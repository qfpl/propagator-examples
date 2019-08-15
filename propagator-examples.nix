{ mkDerivation, base, propagators, stdenv }:
mkDerivation {
  pname = "propagator-examples";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [ base propagators ];
  executableHaskellDepends = [ base propagators ];
  license = stdenv.lib.licenses.bsd3;
}
