{ stdenv, fetchFromGitHub, buildOcaml
, nonstd
}:

buildOcaml rec {
  name = "sosa";
  version = "0.3.0";

  minimumOCamlVersion = "4.02";

  src = fetchFromGitHub {
    owner = "hammerlab";
    repo = name;
    rev = "${name}.${version}";
    sha256 = "053hdv6ww0q4mivajj4iyp7krfvgq8zajq9d8x4mia4lid7j0dyk";
  };

  buildInputs = [ nonstd ];

  buildPhase = "make build";

  doCheck = true;

  meta = with stdenv.lib; {
    homepage = http://www.hammerlab.org/docs/sosa/master/index.html;
    description = "Sane OCaml String API";
    license = licenses.isc;
    maintainers = [ maintainers.alexfmpe ];
  };
}
