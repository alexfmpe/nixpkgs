{
  mkDerivation,
  fetchFromGitHub,
  array,
  base,
  binary,
  bytestring,
  containers,
  deepseq,
  directory,
  filepath,
  ghci,
  lib,
  network,
}:
mkDerivation {
  pname = "iserv-proxy";
  version = "9.3-unstable-2025-10-25";

  # https://github.com/stable-haskell/iserv-proxy/pull/1
  src = fetchFromGitHub {
    owner = "stable-haskell";
    repo = "iserv-proxy";
    rev = "cc7bc12e84947f8e02f6e7a7e336d83daad22a42";
    hash = "sha256-heHXPlwHqPj40oRwOnfQC08xnANpySwyUwIiiVGkX0c=";
  };

  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    array
    base
    binary
    bytestring
    containers
    deepseq
    directory
    filepath
    ghci
    network
  ];
  executableHaskellDepends = [
    base
    binary
    bytestring
    directory
    filepath
    ghci
    network
  ];
  description = "iserv allows GHC to delegate Template Haskell computations";
  license = lib.licenses.bsd3;
}
