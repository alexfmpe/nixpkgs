{ stdenv, lib, fetchFromGitHub
, curl, libzip, openjdk11, openjpeg_2, pcsclite, poppler, pkgconfig, swig4, xercesc, xml-security-c
, qtbase, qtgraphicaleffects, qtquickcontrols2, wrapQtAppsHook
}:
stdenv.mkDerivation rec {
  pname = "autenticacao.gov";
  version = "3.8.0";

  src = fetchFromGitHub {
    owner = "amagovpt";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256:03gxdz2j9mr68pflnqmvnifggw7f2mr9lqw1plz7cnpjj0lgmd35";
  };

  patches = [
    ./openssl3.patch
    ./pkgconfig-pcsclite.patch
  ];

  buildInputs = [
    curl libzip openjdk11 openjpeg_2 pcsclite pkgconfig poppler swig4 xercesc xml-security-c
    qtbase qtgraphicaleffects qtquickcontrols2
  ];

  nativeBuildInputs = [ wrapQtAppsHook ];

  buildPhase = ''
    cd pteid-mw-pt/_src/eidmw
    patchShebangs eidlibJava_Wrapper/create_java_files.sh
    qmake pteid-mw.pro
    make
  '';

  installPhase = ''
    tmpdir=$(mktemp -d)
    mkdir -p $tmpdir/usr/local/bin $tmpdir/usr/local/lib
    INSTALL_ROOT=$tmpdir make install

    mkdir -p $out
    cd $out
    cp -r $tmpdir/usr/local/* .
  '';

  meta = with lib; {
    homepage = "https://www.autenticacao.gov.pt/cc-software";
    description = "Official Middleware for Electronic Identification in Portugal";
    longDescription = ''
      The Autenticação.Gov package provides a utility application (eidguiV2), a set of
      libraries and a PKCS#11 module to use the Portuguese Identity Card
      (Cartão de Cidadão) and Chave Móvel Digital in order to authenticate securely
      in certain websites and sign documents.
    '';
    license = licenses.eupl12;
    maintainers = [ maintainers.alexfmpe ];
    platforms = platforms.linux;
  };

}
