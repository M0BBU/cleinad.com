{
  description = "Build environment for cleinad.com";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          startServer = (pkgs.writeScriptBin "start-server" ''
            #!/bin/bash
            cd html
            python3 -m http.server'');
        in
          with pkgs;
          {
            devShells.default = mkShell {
              buildInputs = [
                python3
                startServer
                tree
              ];
            };
          }
      );
}
