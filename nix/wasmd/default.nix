{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  fetchurl,
}:
  buildGoModule rec {
    pname = "wasmd";
    version = "1.0.0";

    src = fetchFromGitHub {
      owner = "CosmWasm";
      repo = "wasmd";
      rev = "d63bea442bedf5b3055f3821472c7e6cafc3d813";
      sha256 = "sha256-hN7XJDoZ8El2tvwJnW67abhwg37e1ckFyreytN2AwZ0=";
    };

    preCheck = ''
      export HOME=$TMPDIR
    '';
    vendorSha256 = "sha256-NgneotrMk0tPEIvPGyaJ+eD30SAOWVHNNcYnfOEiuvk=";
    doCheck = false;
    meta = with lib; {
      description = "Basic cosmos-sdk app with web assembly smart contracts";
      homepage = "https://github.com/CosmWasm/wasmd";
      license = licenses.mit;
      maintainers = with maintainers; [];
    };

    postInstall = ''
      make install
    '';
  }
