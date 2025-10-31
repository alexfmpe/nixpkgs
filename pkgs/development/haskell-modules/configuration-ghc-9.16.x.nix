{ pkgs, haskellLib }:

let
  inherit (pkgs) lib;

in

with haskellLib;

self: super: {
  # Disable GHC core libraries
  array = null;
  base = null;
  binary = null;
  bytestring = null;
  Cabal = null;
  Cabal-syntax = null;
  containers = null;
  deepseq = null;
  directory = null;
  exceptions = null;
  file-io = null;
  filepath = null;
  ghc-bignum = null;
  ghc-boot = null;
  ghc-boot-th = null;
  ghc-compact = null;
  ghc-experimental = null;
  ghc-heap = null;
  ghc-internal = null;
  ghc-platform = null;
  ghc-prim = null;
  ghc-toolchain = null;
  ghci = null;
  haddock-api = null;
  haddock-library = null;
  haskeline = null;
  hpc = null;
  integer-gmp = null;
  mtl = null;
  os-string = null;
  parsec = null;
  pretty = null;
  process = null;
  rts = null;
  semaphore-compat = null;
  stm = null;
  system-cxx-std-lib = null;
  template-haskell = null;
  terminfo = null;
  text = null;
  time = null;
  transformers = null;
  unix = null;
  xhtml = null;
  Win32 = null;

  call-stack = dontCheck super.call-stack; # broken
  dap = unmarkBroken (doJailbreak super.dap);
  mono-traversable = dontCheck super.mono-traversable; # broken
  regex-tdfa = dontCheck super.regex-tdfa;
  scientific = dontCheck (doJailbreak super.scientific); # slow;

  ghc-exactprint = lib.pipe self.ghc-exactprint_1_14_0_0 [
    doJailbreak
    dontCheck
    (addBuildDepends [ self.syb ])
  ];

  co-log-core = dontCheck (doJailbreak super.co-log-core);

  th-abstraction = dontCheck (doJailbreak super.th-abstraction);
  inspection-testing = dontCheck (doJailbreak super.inspection-testing);

  vector = dontCheck super.vector;

  integer-logarithms = overrideCabal (drv: {
    postPatch = drv.postPatch or "" + ''
      substituteInPlace integer-logarithms.cabal --replace-fail "<1.4" "<1.5"
    '';
  }) (doJailbreak super.integer-logarithms);

  haskell-debugger = overrideCabal (drv: {
    postPatch = drv.postPatch or "" + ''
      substituteInPlace haskell-debugger/GHC/Debugger/Session.hs --replace-fail "MIN_VERSION_ghc(9,14,2)" "MIN_VERSION_ghc(10,0,0)"
    '';
  }) (doJailbreak (dontCheck super.haskell-debugger));

} // (builtins.mapAttrs (_: doJailbreak) {
  inherit (super)
    ChasingBottoms
    OneTuple
    aeson
    assoc
    async
    bifunctors
    boring
    data-fix
    foldl
    generic-deriving
    generically
    hedgehog
    hie-bios
    indexed-traversable
    indexed-traversable-instances
    integer-conversion
    lifted-async
    parallel
    primitive
    quickcheck-instances
    regex-pcre
    regex-pcre-builtin
    semialign
    splitmix
    tagged
    tasty-hedgehog
    tasty-inspection-testing
    text-short
    th-compat
    th-expand-syns
    th-lift
    th-orphans
    these
    time-compat
    unordered-containers
    uuid-types
    wherefrom-compat
    witherable

    aeson-gadt-th
    some
    haskell-src-meta
    dependent-map
    dependent-sum
    dependent-sum-template
    constraints-extras
  ;
})
