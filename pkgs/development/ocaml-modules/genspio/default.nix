{ stdenv, fetchFromGitHub, buildDunePackage }:

buildDunePackage rec {
  pname = "genspio";
  version = "0.0.2";

  minimumOCamlVersion = "4.03";

  src = fetchFromGitHub {
    owner = "hammerlab";
    repo = pname;
    rev = "genspio.${version}";
    sha256 = "0cp6p1f713sfv4p2r03bzvjvakzn4ili7hf3a952b3w1k39hv37x";
  };

  doCheck = true;

  meta = with stdenv.lib; {
    homepage = https://smondet.gitlab.io/genspio-doc/;
    description = "Typed EDSL to generate POSIX Shell scripts";
    license = licenses.asl20;
    maintainers = [ maintainers.alexfmpe ];
  };
}
