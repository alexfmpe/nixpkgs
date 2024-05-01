# NIXPKGS_ALLOW_BROKEN=1 nix-build test.nix --no-out-link --keep-going --arg pkgs '[ "records-sop" "patch" ] '

{ pkgs
, unmarkBroken ? false
, doJailbreak ? false
, dontCheck ? false
}:
let
  nixpkgs = import ./. {};
  inherit (nixpkgs) haskell lib stdenv;
  id = x: x;

  packageSets =
    let
      currentSystem = ghc-version: pkgs: pkgs.haskell.packages."ghc${ghc-version}";
      cross = platform: pkgs: pkgs.pkgsCross.${platform}.haskellPackages;
    in
      builtins.map cross [
        "ghcjs"
#        "mingwW64"
      ] ++ lib.optionals stdenv.isDarwin [
#        (cross "iphone64")
      ] ++ lib.optionals stdenv.isLinux [
#        (cross "aarch64-android")
      ] ++ builtins.map currentSystem [
        "810"
#        "90"
#        "92"
        "94"
        "96"
        "98"
      ];

  compilers = [ "ghc810" "ghc90" "ghc92" "ghc94" "ghc96" "ghc98" ];
  pass = flag: mod: if flag then mod else id;

  buildPkg' = getPackageSet: pkg: (getPackageSet nixpkgs).${pkg};

  # TODO: override in package set so it applies when a dep
  buildPkg = pkg: compiler: lib.pipe nixpkgs.haskell.packages.${compiler}.${pkg}
    [ (pass unmarkBroken haskell.lib.unmarkBroken)
      (pass doJailbreak  haskell.lib.doJailbreak )
      (pass dontCheck    haskell.lib.dontCheck )
    ];
  liftA2 = f: xs: ys: builtins.concatLists (builtins.map (x:  builtins.map (f x) ys) xs);
in
  # liftA2 buildPkg pkgs compilers
  liftA2 buildPkg' packageSets pkgs
