{ pkgs, haskellLib }:

let
  inherit (pkgs) lib;
in

with haskellLib;

self: super: builtins.mapAttrs (_: dontCheck) {
  inherit (super)
    # Mmap.hsc: In function ‘_hsc2hs_test13’:
    # Mmap.hsc:54:20: error: storage size of ‘test_array’ isn’t constant
    hashable

    # could not execute: htfpp
    list-t

    # Haskell pre-processor: could not execute: hspec-discover
    countable-inflections
    data-diverse
    here
    hi-file-parser
    hspec-attoparsec
    interpolate
    mime-mail
    project-template
    rio-orphans
    say
    string-conversions
    text-zipper

    # posix_spawnp: invalid argument (Exec format error)
    #   | {-# OPTIONS_GHC -F -pgmF hspec-discover #-}
    hspec-wai
    http-date
    http-types
    safe-exceptions
    tasty-discover
    unliftio
    word8
    yaml

    # https://gitlab.haskell.org/ghc/ghc/-/issues/14335
    # <no location info>: error: Plugins require -fno-external-interpreter
    algebraic-graphs
    generic-lens
    ghc-typelits-knownnat
    ghc-typelits-natnormalise
    infer-license
    inspection-testing
    large-records
    linear-base
    postgresql-simple
    typerep-map

    # Exception when trying to run compile-time code:
    #   External interpreter terminated (1)
    aeson
    aeson-gadt-th
    aeson-qq
    bifunctors
    bytebuild
    generic-deriving
    github
    haskell-src-meta
    hedgehog
    hpack
    lens
    microlens-th
    minio-hs
    modern-uri
    monad-par
    nonempty-containers
    optics-th
    persistent
    snap
    toml-parser
    wide-word
  ;
}
