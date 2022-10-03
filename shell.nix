{pkgs}: let
  rustTargetWasm =
    pkgs.rust-bin.stable.latest.default.override
    {
      extensions = ["rust-src"];
      targets = ["wasm32-unknown-unknown"];
    };

  wasmd = pkgs.callPackage ./nix/wasmd;
in
  pkgs.mkShell {
    packages = [
      pkgs.metacraft-labs.cosmos-theta-testnet # <after>
      rustTargetWasm
      pkgs.go

      wasmd
    ];
    shellHook = ''
      export GAIAD_BOOSTTRAP_DATA_DIR=${pkgs.metacraft-labs.cosmos-theta-testnet}/data

      figlet "Cosmos Playground"
    '';
  }
