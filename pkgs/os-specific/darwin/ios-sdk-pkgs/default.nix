{ lib, hostPlatform, targetPlatform
, clang-unwrapped
, binutils-unwrapped
, requireFile
, runCommand
, stdenv
, wrapBintoolsWith
, wrapCCWith
, buildIosSdk, targetIosSdkPkgs
}:

let

minSdkVersion = "9.0";

iosPlatformArch = { parsed, ... }: {
  "armv7a"  = "armv7";
  "aarch64" = "arm64";
  "x86_64"  = "x86_64";
}.${parsed.cpu.name};

# TODO(alexfmpe):
# tests?
# allow extracting/validating .xip in linux: does the nix hash make validating useless?
# handle XCode patch versions: do they change the SDKs? if so, how to distinguish/identify them?
# turn instructions into a proper script and run in temporary directory
# check if *running* the simulator requires extra deps - there's a suspiciously large size difference between 10.x and 11.x simulator SDKs
requireSDK = { sdkType, version }:
  with sdks."${sdkType + version}";
  let xcode = "Xcode_${xcodeVersion}";
      xip   = "${xcode}.xip";
      iPhoneOS  = "iPhoneOS";
      iPhoneSim = "iPhoneSimulator";
      cpFromXcode = s: "cp -R Xcode.app/Contents/Developer/Platforms/${s}.platform/Developer/SDKs/${s}.sdk ${s + version}.sdk";
      nixStoreAdd = s: "nix-store --add-fixed --recursive sha256 ${s + version}.sdk";
      cleanup     = s: "rm -rf ${s + version}.sdk";
  in requireFile rec {
    name = "iPhone${sdkType}${version}.sdk";
    url = "https://download.developer.apple.com/Developer_Tools/${xcode}/${xip}";
    hashMode = "recursive";
    message = ''
      Unfortunately, we cannot download ${name} automatically.
      Please go to ${url}
      to download it yourself, and add it to the Nix store by running the following commands in OS X.

      Notes:
      - download (~ 4GB) and extraction of xcode will take a while, so it might be best to get both ios SDKs
      - the 10.x versions of the simulator SDK are *very* bulky (over 2GB): make sure you have enough memory and disk space

        open -W ${xip}
        rm -rf ${xip}
        ${cpFromXcode iPhoneOS }
        ${cpFromXcode iPhoneSim}
        rm -rf Xcode.app
        ${nixStoreAdd iPhoneOS }
        ${nixStoreAdd iPhoneSim}
        ${cleanup     iPhoneOS }
        ${cleanup     iPhoneSim}
    '';
    inherit sha256;
  };

sdks = {
  "OS10.1"        = { xcodeVersion = "8.1"; sha256 = "1zzq36jiq5hwlcl1a6zmsail1bxbajmqwnpswvx2p3232m8iv3d8"; };
  "OS10.2"        = { xcodeVersion = "8.2"; sha256 = "0a31qir54zawsf1x5jjkszdvx8gch5dcr26m26j5mimbnahr8bsc"; };
  "OS10.3"        = { xcodeVersion = "8.3"; sha256 = "1ajs5wbjkfv3xgxbjni7mh0pmmf6x9pk74knra147p3xjdwx040k"; };
  "Simulator10.1" = { xcodeVersion = "8.1"; sha256 = "0iyxf0rn696aphlqsybn4nc5cw8wsz51czy3dz280qb52kkcsz4s"; };
  "Simulator10.2" = { xcodeVersion = "8.2"; sha256 = "1py0d3hbrndnpjsvycvhzsp8017wq6nr9il6j6nxiqsg2dsqscp8"; };
  "Simulator10.3" = { xcodeVersion = "8.3"; sha256 = "0y34582411pawxi3wkwsz7wxlln5f9ini1a98wac7d4h61r5xank"; };
};

in

rec {
  sdk = rec {
    name = "ios-sdk";
    type = "derivation";
    outPath = requireSDK { inherit sdkType version; };

    sdkType = if targetPlatform.isiPhoneSimulator then "Simulator" else "OS";
    version = targetPlatform.sdkVer;
  };

  binutils = wrapBintoolsWith {
    libc = targetIosSdkPkgs.libraries;
    bintools = binutils-unwrapped;
    extraBuildCommands = ''
      echo "-arch ${iosPlatformArch targetPlatform}" >> $out/nix-support/libc-ldflags
    '';
  };

  clang = (wrapCCWith {
    cc = clang-unwrapped;
    bintools = binutils;
    libc = targetIosSdkPkgs.libraries;
    extraBuildCommands = ''
      tr '\n' ' ' < $out/nix-support/cc-cflags > cc-cflags.tmp
      mv cc-cflags.tmp $out/nix-support/cc-cflags
      echo "-target ${targetPlatform.config} -arch ${iosPlatformArch targetPlatform}" >> $out/nix-support/cc-cflags
      echo "-isystem ${sdk}/usr/include -isystem ${sdk}/usr/include/c++/4.2.1/ -stdlib=libstdc++" >> $out/nix-support/cc-cflags
      echo "${if targetPlatform.isiPhoneSimulator then "-mios-simulator-version-min" else "-miphoneos-version-min"}=${minSdkVersion}" >> $out/nix-support/cc-cflags
    '';
  }) // {
    inherit sdk;
  };

  libraries = let sdk = buildIosSdk; in runCommand "libSystem-prebuilt" {
    passthru = {
      inherit sdk;
    };
  } ''
    if ! [ -d ${sdk} ]; then
        echo "You must have version ${sdk.version} of the iPhone${sdk.sdkType} sdk installed at ${sdk}" >&2
        exit 1
    fi
    ln -s ${sdk}/usr $out
  '';
}
