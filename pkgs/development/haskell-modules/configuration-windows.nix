{ pkgs, haskellLib }:

let
  inherit (pkgs) fetchpatch lib;
in

with haskellLib;

let
  exts = {
    patches = self: super: builtins.mapAttrs (n: v: appendPatch v super.${n}) {
      # * Missing (or bad) C library: Crypt32
      crypton-x509-system = ./patches/crypton-x509-system.patch;

      # Size.hsc:126:30: error: initialization of ‘long long int’ from ‘void *’ makes integer from pointer without a cast [-Wint-conversion]
      basement = ./patches/basement-add-cast.patch;
    };

    addBuildDepends = self: super: builtins.mapAttrs (n: v: addBuildDepends v super.${n}) {

      # cabal2nix doesn't properly add dependencies conditional on os(windows)
      network = [ self.temporary ];
      unix-time = [ pkgs.windows.pthreads ];
      http-client = [ self.safe ];
      regex-posix = [ self.regex-posix-clib ];
      echo = [ self.mintty ];
      tar-conduit = [ self.unix-compat ];
      warp = [ self.unix-compat ];

      simple-sendfile = with self; [ conduit conduit-extra resourcet ]; # Coincidentally added by test suite
    };

    # Mingw-w64 runtime failure:
    # 32 bit pseudo relocation at 00000001400EB99E out of range, targeting 00006FFFFFEB8170, yielding the value 00006FFEBFDCC7CE.
    workaroundRelocationErrors = self: super:
      let workaround = appendConfigureFlags ["--ghc-option=-optl-Wl,--disable-dynamicbase,--disable-high-entropy-va,--image-base=0x400000"];
      in builtins.mapAttrs (_: workaround) {
        inherit (super)
          co-log-core
          ghc-lib-parser-ex
          hiedb
          hw-fingertree
          hw-prim
          ihp-hsx
          iserv-proxy
          pcg-random
          slist
          swagger2
          turtle
          validation-selective
        ;
      };

    disableProfiling = self: super: builtins.mapAttrs (_: disableLibraryProfiling) {
      inherit (super)

        # x86_64-w64-mingw32-binutils-2.44/bin/x86_64-w64-mingw32-ld: dist/build/Language/Haskell/Exts/Syntax.p_o: too many sections (87219)
        # x86_64-w64-mingw32-binutils-2.44/bin/x86_64-w64-mingw32-ld: final link failed: file too big
        ghc-lib-parser
        haskell-src-exts
        jsaddle-dom
        swagger2

        # Transitively depend on above
        aeson-qq
        ghc-exactprint
        ghc-lib-parser-ex
        ghcjs-dom
        haskell-src-meta
        interpolate
        reflex
        reflex-dom-core
        reflex-gadt-api
        string-interpolate
        test-framework-th
        vessel
      ;
    };

    dontCheck = self: super: builtins.mapAttrs (_: dontCheck) {
      inherit (super)

        # Miscelanneous
        atomic-write      # File permission mismatches
        http2             # tests hang
        retry             # Time sensitive tests?
        rio               # Executable named echo not found on path
        simple-sendfile   # https://github.com/haskell/network/issues/604
        wherefrom-compat  # tests fail

        # Network.Socket.accept: failed (Unknown WinSock error: 995)
        conduit-extra
        streaming-commons

        # does not exist (No such file or directory)
        Diff # diff
        aeson # diff
        typed-process # base64 cat false sh sleep

        blaze-builder      # commitAndReleaseBuffer: invalid argument (cannot encode character '\8594')
        mod                # commitBuffer: invalid argument (cannot encode character '\8801')
        quickcheck-classes # commitBuffer: invalid argument (cannot encode character '\8801')
        text-metrics       # commitBuffer: invalid argument (cannot encode character '\128512')

        config-ini         # hGetContents: invalid argument (cannot decode byte sequence starting from 129)
        hspec-hedgehog     # hGetContents: invalid argument (cannot decode byte sequence starting from 143)
        tomland            # hGetContents: invalid argument (cannot decode byte sequence starting from 157)

        # Hang during test suite build:
        #   [iserv-proxy-interpreter.exe] wrapRunTH...
        aeson-qq
        algebraic-graphs
        haskell-src-meta
        hpack
        persistent
        persistent-test
        string-interpolate

        # user error (/nix/store/<hash>-<ghc>/bin/x86_64-w64-mingw32-ghc-9.12.2 is not executable!)
        hw-prim
        swagger2

        # 0024:err:module:import_dll Library libffi-8.dll (which is needed by L"Z:\\build\\HUnit-1.6.2.0\\dist\\build\\tests\\tests.exe") not found
        HUnit

        # 0024:err:virtual:virtual_setup_exception stack overflow 1856 bytes addr 0x7fffe9b832dd stack 0x208c0 (0x20000-0x21000-0x220000)
        QuickCheck
        bimap
        file-embed
        hedgehog
        optparse-applicative
        th-lift-instances
        quickcheck-text
        patch
        monad-par

        ## Actually broken test suites
        ## path separator induced test failures
        # Glob
        # tasty-golden

        # > expected: (ExitSuccess,"a\nc","b\n")
        # >  but got: (ExitSuccess,"","a; echo b  printf c\n")
        process-extras
      ;
    };

    misc = self: super: {
      # https://github.com/fpco/streaming-commons/pull/84
      streaming-commons = lib.pipe super.streaming-commons [
        (appendPatch (fetchpatch {
          name = "fix-headers-case.patch";
          url = "https://github.com/fpco/streaming-commons/commit/6da611f63e9e862523ce6ee53262ddbc9681ae24.patch";
          sha256 = "sha256-giEQqXZfoiAvtCFohdgOoYna2Tnu5aSYAOUH8YVldi0=";
        }))
        (addBuildDepends [ pkgs.zlib ] ) # Why?
      ];
    };
  };
in
lib.composeManyExtensions [
  exts.patches
  exts.addBuildDepends
  exts.disableProfiling
  exts.workaroundRelocationErrors
  exts.dontCheck
  exts.misc
]
