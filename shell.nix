{pkgs}:
with pkgs;
  mkShell {
    packages = [
      metacraft-labs.cosmos-theta-testnet # <after>
      rust-bin.beta.latest.default
    ];
    shellHook = ''
      export GAIAD_BOOSTTRAP_DATA_DIR=${metacraft-labs.cosmos-theta-testnet}/data

      figlet "Cosmos Playground"
    '';
  }
