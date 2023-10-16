{ lib, buildPythonApplication, fetchPypi, fleep, libarchive-c, pillow
, requests-toolbelt, setuptools, zeroconf, openssl # Adding openssl
, makeWrapper # Adding makeWrapper
}:

buildPythonApplication rec {
  pname = "opendrop";
  version = "0.13.0";

  src = fetchPypi {
    inherit version pname;
    sha256 = "sha256-FE1oGpL6C9iBhI8Zj71Pm9qkObJvSeU2gaBZwK1bTQc=";
  };

  propagatedBuildInputs = [
    fleep
    libarchive-c
    pillow
    requests-toolbelt
    setuptools
    zeroconf
    openssl # Adding openssl to build inputs
  ];

  nativeBuildInputs = [
    makeWrapper # Adding makeWrapper to native build inputs
  ];

  # Wrapping the binary to ensure openssl is in its PATH at runtime
  postFixup = ''
    wrapProgram $out/bin/opendrop \
      --prefix PATH : ${lib.makeBinPath [ openssl ]}
  '';

  # There are tests, but getting the following error:
  # nix_run_setup: error: argument action: invalid choice: 'test' (choose from 'receive', 'find', 'send')
  # Opendrop works as intended though
  doCheck = false;

  meta = with lib; {
    description = "An open Apple AirDrop implementation written in Python";
    homepage = "https://owlink.org/";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ wolfangaukang ];
    platforms = [ "x86_64-linux" ];
  };
}
