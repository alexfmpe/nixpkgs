{ stdenv, requireFile }:

let requireXcode = version: sha256:
  let
      xip   = "Xcode_" + version +  ".xip";
      app   = requireFile rec {
        name     = "Xcode.app";
        url      = "https://download.developer.apple.com/Developer_Tools/Xcode_" + version + "/" + xip;
        hashMode = "recursive";
        inherit sha256;
        message  = ''
          Unfortunately, we cannot download ${name} automatically.
          Please go to ${url}
          to download it yourself, and add it to the Nix store by running the following commands in OS X.
          Note: download (~ 5GB), extraction and storing of Xcode will take a while

          open -W ${xip}
          rm -rf ${xip}
          nix-store --add-fixed --recursive sha256 Xcode.app
          rm -rf Xcode.app
        '';
    };
    meta = {
      homepage = https://developer.apple.com/downloads/;
      description = "Apple's XCode SDK";
      license = stdenv.lib.licenses.unfree;
      platforms = stdenv.lib.platforms.darwin;
    };

  in app.overrideAttrs ( oldAttrs: oldAttrs // { inherit meta; });

in {
  xcode_8_2 = requireXcode "8.2" "13nd1zsfqcp9hwp15hndr0rsbb8rgprrz7zr2ablj4697qca06m2";
}
