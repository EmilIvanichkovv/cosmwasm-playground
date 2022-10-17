{pkgs}: let
  rustTargetWasm =
    pkgs.rust-bin.nightly.latest.default.override
    {
      extensions = ["rust-src"];
      targets = ["wasm32-unknown-unknown"];
    };

  emscripten-enriched-cache = pkgs.emscripten.overrideAttrs (old: {
    postInstall = ''
      pushd $TMPDIR
      echo 'int __main_argc_argv() { return 42; }' >test.c
      for MEM in "-s ALLOW_MEMORY_GROWTH" ""; do
        for LTO in -flto ""; do
          for OPT in "-O2" "-O3" "-Oz" "-Os"; do
            for REALOC in "-s RELOCATABLE=1" ""; do
              for NOENTRY in "--no-entry" ""; do
                $out/bin/emcc $MEM $LTO $OPT $REALOC $NOENTRY -s WASM=1 -s STANDALONE_WASM test.c
              done
            done
          done
        done
      done
    '';
  });
in
  pkgs.mkShell {
    packages = [
      pkgs.metacraft-labs.cosmos-theta-testnet # <after>
      rustTargetWasm
      pkgs.rustup
      pkgs.go
      pkgs.metacraft-labs.wasmd

      pkgs.jq

      pkgs.binaryen

      emscripten-enriched-cache
    ];
    shellHook = ''
      export GAIAD_BOOSTTRAP_DATA_DIR=${pkgs.metacraft-labs.cosmos-theta-testnet}/data

      figlet "Cosmos Playground"

    '';
  }
