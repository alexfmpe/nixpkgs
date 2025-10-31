# with (import ./. {}).pkgsCross.ucrt64.haskell.packages.native-bignum.ghc912; {
# with (import ./. {}).pkgsCross.raspberryPi.haskell.packages.native-bignum.ghc912; {
{ version ? "ghcHEAD" }:
let
  nixpkgs = (import ./. {});
  cross = nixpkgs.pkgsCross.aarch64-multiplatform;
  hsPkgs = cross.haskell.packages.native-bignum.${version};
  prefix = cross.hostPlatform.config;

#   qemu-aarch64

  ghc-cross = nixpkgs.writeShellScriptBin "ghc" ''${prefix}-ghc "$@"'';
  ghc-pkg-cross = nixpkgs.writeShellScriptBin "ghc-pkg" ''${prefix}-ghc-pkg "$@"'';

#  cabal-install-cross = nixpkgs.writeShellScriptBin "${prefix}-cabal" ''
  cabal-install-cross = nixpkgs.writeShellScriptBin "cabal" ''
    ${nixpkgs.cabal-install}/bin/cabal \
      --with-compiler=${prefix}-ghc \
      --with-hc-pkg=${prefix}-ghc-pkg \
      --with-hsc2hs=${prefix}-hsc2hs \
      "$@"
  '';

in {
  inherit nixpkgs prefix cabal-install-cross;
  build = hsPkgs.haskell-debugger;
/*
  shell = hsPkgs.shellFor {
    packages = ps: []; # hsPkgs.haskell-debugger ];
    nativeBuildInputs = [
      cabal-install-cross
      # hsPkgs.haskell-debugger
      nixpkgs.haskell.packages.native-bignum.${version}.haskell-debugger
      nixpkgs.pkg-config
    ];
    buildInputs = [
      cross.zlib
    ];
    inputsFrom = [];
  };
*/

  shell = with nixpkgs; mkShell {
    packages = [
      cabal-install-cross
      ghc-cross
      ghc-pkg-cross
      hsPkgs.ghc
      hsPkgs.haskell-debugger
      # nixpkgs.haskell.packages.native-bignum.${version}.haskell-debugger
      #      emscripten
      #      nodejs

      cross.glibc
    ];
  };

}
