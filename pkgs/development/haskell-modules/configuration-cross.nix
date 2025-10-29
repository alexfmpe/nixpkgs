{ pkgs, haskellLib }:

let
  inherit (pkgs) lib;
in

with haskellLib;

self: super: {
  # Avoids a cycle by disabling use of the external interpreter by the packages that are dependencies of iserv-proxy
  # These in particular can't rely on template haskell for cross-compilation anyway as they can't rely on iserv-proxy
  inherit
    (
      let
        breakCycle = overrideCabal {
          doCheck = false; # test packages themselves like to rely on TH for discovering test cases
          enableExternalInterpreter = false;
        };
      in
      lib.mapAttrs (_: breakCycle) { inherit (super) iserv-proxy libiserv network temporary splitmix random
        th-lift th-abstraction syb th-reify-many safe th-compat
        th-expand-syns ;}
    )
    iserv-proxy
    libiserv
    network
    temporary
    splitmix
    random
    th-lift th-abstraction syb th-reify-many safe th-compat
    th-expand-syns
    ;

  # qemu: uncaught target signal 4 (Illegal instruction) - core dumped
  # th-expand-syns = dontCheck super.th-expand-syns;

  # test/Unicode/CharSpec.hs:206:21:
  # 1) Unicode.Char.Case toUpper
  #      predicate failed on: '\411'
  unicode-data = dontCheck super.unicode-data;

  # syntax error: unexpected word (expecting ")")
  jsaddle-warp = dontCheck super.jsaddle-warp;

  # syntax error: unterminated quoted string
  cabal2nix = dontCheck super.cabal2nix;
  pandoc = dontCheck super.pandoc;

  # Tests take a long time or maybe hang
  bitvec = dontCheck super.bitvec;
  crypton = dontCheck super.crypton;
  crypton-x509-validation = dontCheck super.crypton-x509-validation;
  tls = dontCheck super.tls;

  # Test suite rootCleanup: FAIL
  reflex = dontCheck super.reflex;

  # Couldn't find a target code interpreter. Try with -fexternal-interpreter
  bsb-http-chunked = dontCheck super.bsb-http-chunked;
  doctest-parallel = dontCheck super.doctest-parallel;
  foldl = dontCheck super.foldl;

  # https://gitlab.haskell.org/ghc/ghc/-/issues/14335
  # <no location info>: error: Plugins require -fno-external-interpreter
  algebraic-graphs = dontCheck super.algebraic-graphs;
  ghc-typelits-knownnat = dontCheck super.ghc-typelits-knownnat;
  ghc-typelits-natnormalise = dontCheck super.ghc-typelits-natnormalise;
  infer-license = dontCheck super.infer-license;
  inspection-testing = dontCheck super.inspection-testing;
  large-records = dontCheck super.large-records;
  vector = dontCheck super.vector;

  # quasi-quotation failure:
  #   Exception when trying to run compile-time code:
  #    External interpreter terminated (1)
  aeson-qq = dontCheck super.aeson-qq;
  bytebuild = dontCheck super.bytebuild;

  # could not execute: htfpp
  list-t = dontCheck super.list-t;

  # could not execute: hspec-discover
  countable-inflections = dontCheck super.countable-inflections;
  data-diverse = dontCheck super.data-diverse;
  here = dontCheck super.here;
  hi-file-parser = dontCheck super.hi-file-parser;
  hspec-attoparsec = dontCheck super.hspec-attoparsec;
  hspec-wai = dontCheck super.hspec-wai;
  http-date = dontCheck super.http-date;
  http-types = dontCheck super.http-types;
  mime-mail = dontCheck super.mime-mail;
  project-template = dontCheck super.project-template;
  rio-orphans = dontCheck super.rio-orphans;
  say = dontCheck super.say;
  string-conversions = dontCheck super.string-conversions;
  text-zipper = dontCheck super.text-zipper;
  unliftio = dontCheck super.unliftio;
  word8 = dontCheck super.word8;
  yaml = dontCheck super.yaml;

  # posix_spawnp: invalid argument (Exec format error)
  file-lock = dontCheck super.file-lock;
  safe-exceptions = dontCheck super.safe-exceptions;
  tasty-discover = dontCheck super.tasty-discover;
  warp = dontCheck super.warp;
  zip-archive = dontCheck super.zip-archive;

  # Mmap.hsc: In function ‘_hsc2hs_test13’:
  # Mmap.hsc:54:20: error: storage size of ‘test_array’ isn’t constant
  hashable = dontCheck super.hashable;

  # doctest related errors:
  #   Couldn't find a target code interpreter. Try with -fexternal-interpreter
  co-log-core = dontCheck super.co-log-core;
  doctest = dontCheck super.doctest;
  hw-fingertree = dontCheck super.hw-fingertree;
  hw-hspec-hedgehog = dontCheck super.hw-hspec-hedgehog;
  pcg-random = dontCheck super.pcg-random;
  slist = dontCheck super.slist;
  trial = dontCheck super.trial;
  turtle = dontCheck super.turtle;
  validation-selective = dontCheck super.validation-selective;
  xml-conduit = dontCheck super.xml-conduit;
}
