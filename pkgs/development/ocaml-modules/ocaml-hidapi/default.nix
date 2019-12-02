{ stdenv, fetchFromGitHub, buildDunePackage, pkg-config
, bigstring, hidapi,
}:

buildDunePackage rec {
  pname = "hidapi";
  version = "1.1.1";

  minimumOCamlVersion = "4.02";

  src = fetchFromGitHub {
    owner = "vbmithr";
    repo = "ocaml-hidapi";
    rev = version;
    sha256 = "1qhc8iby3i54zflbi3yrnhpg62pwdl6g2sfnykgashjy7ghh495y";
  };

  buildInputs = [ bigstring hidapi pkg-config ];

  doCheck = true;

  meta = with stdenv.lib; {
    homepage = https://github.com/vbmithr/ocaml-hidapi;
    description = "Bindings to Signal11's hidapi library";
    license = licenses.isc;
    maintainers = [ maintainers.alexfmpe ];
  };
}
