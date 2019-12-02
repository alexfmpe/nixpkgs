{ stdenv, lib, fetchFromGitHub, fetchFromGitLab, recurseIntoAttrs
, hidapi, pkg-config
, ocaml-ng, buildDunePackage
, astring, base64, cmdliner, cohttp-lwt, cohttp-lwt-unix, cstruct, digestif, domain-name, dum
, ezjsonm, fmt, genspio, hex, ipaddr, jsonm, js_of_ocaml, logs, lwt_log, macaddr, mtime
, ocaml_lwt, ocamlgraph, ocplib-endian, ocp-ocamlres, pprint, sexplib, tls, uri, zarith
, bigstring, irmin, ocaml-hidapi
}:

let
  tezos = buildDunePackage rec {
    pname = "tezos";
    version = "lol";

    buildInputs = [ bigstring cmdliner cohttp-lwt cohttp-lwt-unix dum
                    ezjsonm irmin genspio lwt_log js_of_ocaml mtime
                    ipaddr macaddr
                    ocamlgraph ocaml-hidapi ocplib-endian ocp-ocamlres pprint tls zarith
                  ];

    buildPhase = ''
      echo "============BUILD==============="
      runHook preBuild
      dune build
      runHook postBuild
      echo "============BUILD==============="
    '';

    checkPhase = ''
      echo "============CHECK==============="
    '';
    installPhase = ''
      echo "============INSTALL==============="
    '';
    #  minimumOCamlVersion = "4.08.1";

    #  buildInputs = [ alcotest ];
    #  propagatedBuildInputs = [ bigstringaf result ];
    #  doCheck = true;

    hardeningDisable = stdenv.lib.optional stdenv.isDarwin "strictoverflow";

    src = fetchFromGitLab {
      owner  = "tezos";
      repo   = pname;
      #    branch = "mainnet";
      rev    = "0f0a78e85bc41b20f37175791e21c7098d089eb8";
      sha256 = "10bdk5bxg8fhq3blzmyrpgnk2p9bxql3agcdnsnb8179w5mjwv81";
    };
  };

in tezos
