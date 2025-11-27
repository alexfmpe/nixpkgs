{ pkgs, haskellLib }:

let
  inherit (pkgs) fetchpatch lib;
in

with haskellLib;

(self: super: {
  # cabal2nix doesn't properly add dependencies conditional on os(windows)
  network =
    if pkgs.stdenv.hostPlatform.isWindows then
      addBuildDepends [ self.temporary ] super.network
    else
      super.network;

  # https://github.com/fpco/streaming-commons/pull/84
  streaming-commons = appendPatch (fetchpatch {
    name = "fix-headers-case.patch";
    url = "https://github.com/fpco/streaming-commons/commit/6da611f63e9e862523ce6ee53262ddbc9681ae24.patch";
    sha256 = "sha256-giEQqXZfoiAvtCFohdgOoYna2Tnu5aSYAOUH8YVldi0=";
  }) super.streaming-commons;

  # Mingw-w64 runtime failure:
  # 32 bit pseudo relocation at 00000001400EB99E out of range, targeting 00006FFFFFEB8170, yielding the value 00006FFEBFDCC7CE.
  iserv-proxy = appendConfigureFlags ["--ghc-option=-optl-Wl,--disable-dynamicbase,--disable-high-entropy-va,--image-base=0x400000"] super.iserv-proxy;
})
