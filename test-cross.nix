with (import ./. {}).pkgsCross.aarch64-multiplatform.haskell.packages.ghc912; {
# with (import ./. {}).pkgsCross.ucrt64.haskell.packages.native-bignum.ghc912; {
# with (import ./. {}).pkgsCross.raspberryPi.haskell.packages.native-bignum.ghc912; {
 inherit
   cabal2nix
   ghcid
   haskell-debugger
   haskell-language-server
   # hlint
   stack

   # gargoyle-postgresql-connect
   # nix-thunk
   proto3-suite

   miso
   # reflex-dom-core
   reflex-gadt-api
   vessel

   path

   # snap
   jsaddle-warp

   # cryptonite-openssl
   # x509-system

   # ihp
 ;
}
