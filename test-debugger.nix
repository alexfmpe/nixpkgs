# with (import ./. {}).pkgsCross.ucrt64.haskell.packages.native-bignum.ghc912; {
# with (import ./. {}).pkgsCross.raspberryPi.haskell.packages.native-bignum.ghc912; {
{ version ? "ghcHEAD" }:
let
  nixpkgs = (import ./. {});
  cross = nixpkgs.pkgsCross.aarch64-multiplatform;
  hsPkgs = cross.haskell.packages.${version};
  prefix = cross.hostPlatform.config;
  cabal-install-cross = nixpkgs.writeShellScriptBin "${prefix}-cabal" ''
    ${nixpkgs.cabal-install}/bin/cabal \
      --with-compiler=${prefix}-ghc \
      --with-hc-pkg=${prefix}-ghc-pkg \
      --with-hsc2hs=${prefix}-hsc2hs \
      "$@"
  '';

in {
  inherit nixpkgs prefix cabal-install-cross;
  build = hsPkgs.haskell-debugger;
  shell = nixpkgs.mkShell {
    packages = [
      nixpkgs.cabal-install
      cabal-install-cross
#      emscripten
#      nodejs
      hsPkgs.ghc
    ];
  };
}

/*
in {
  inherit nixpkgs;
  build = js-version.impli;
  shell = with nixpkgs; mkShell {
    packages = [
      cabal-install-ghcjs
      emscripten
      nodejs
      js-version.ghc
    ];
  };
}
*/
