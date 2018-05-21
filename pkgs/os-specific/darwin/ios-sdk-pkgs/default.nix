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
  let xcodeVersion = xcode.forSDK."${sdkType + version}";
      versionedApp = "Xcode${xcodeVersion}.app";
      xip   = "Xcode_" + xcodeVersion +  ".xip";
      unxip = if stdenv.isDarwin
              then "open -W ${xip}"
              else ''
                xar -xf ${xip}
                pbzx -n Content | cpio -i
              '';

      app = requireFile rec {
        name     = "Xcode.app";
        url      = "https://download.developer.apple.com/Developer_Tools/Xcode_" + xcodeVersion + "/" + xip;
        hashMode = "recursive";
        sha256   = xcode.hashes."${xcodeVersion}";

        message  = ''
          Unfortunately, we cannot download ${name} automatically.
          Please go to ${url}
          to download it yourself, and add it to the Nix store by running the following commands in OS X.  
          Note: download (~ 5GB), extraction and storing of xcode will take a while

          ${unxip}
          rm -rf ${xip}
          mv Xcode.app ${versionedApp}
          nix-store --add-fixed --recursive sha256 ${versionedApp}
          rm -rf ${versionedApp}
        '';
      };
  in app + "/Contents/Developer/Platforms/iPhone${sdkType}.platform/Developer/SDKs/iPhone${sdkType}${version}.sdk";

xcode = {
  hashes = {
    "8.2" = "13nd1zsfqcp9hwp15hndr0rsbb8rgprrz7zr2ablj4697qca06m2";
  };
  forSDK = {
    "OS10.2"        = "8.2";
    "Simulator10.2" = "8.2";
  };
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
