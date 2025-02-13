# nix-build test.nix --no-out-link --keep-going --arg pkgs '[ "hello" ]'

{ pkgs
}:
let
  nixpkgs = import ./. {};
  inherit (nixpkgs) haskell lib stdenv;
  id = x: x;

  packageSets =
    let
      currentSystem = build id;
      cross = platform: build (pkgs: pkgs.pkgsCross.${platform});

      build = getPlatform: ghc-version: pkgs: (getPlatform pkgs).haskell.packages."ghc${ghc-version}";

    in
      [
        (cross "ghcjs" "912")
#        (cross "mingwW64" "910")
      ] ++ lib.optionals stdenv.isDarwin [
#        (cross "iphone64" "910")
      ] ++ lib.optionals stdenv.isLinux [
#        (cross "aarch64-android" "910")
      ] ++ builtins.map currentSystem [
#        "810"
#        "90"
#        "92"
#        "94"
#        "96"
        "98"
#        "910"
      ];

  buildPkg = getPackageSet: pkg: (getPackageSet nixpkgs).${pkg};

  liftA2 = f: xs: ys: builtins.concatLists (builtins.map (x:  builtins.map (f x) ys) xs);
in
  liftA2 buildPkg packageSets pkgs
