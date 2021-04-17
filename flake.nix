{
  description = "Play YouTube videos from the command line in a convenient way";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:

    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # Use mpv with scripts
          mpv = (pkgs.mpv-with-scripts.override {
            scripts = [
              pkgs.mpvScripts.mpris
              pkgs.mpvScripts.sponsorblock
            ];
          });

          dependencies = with pkgs; [
            jq
            mpv
            youtube-dl
          ];

        in
        {

          # Package

          packages.tyt =

            pkgs.stdenv.mkDerivation {

              name = "tyt";
              src = self;

              buildInputs = dependencies;

              patchPhase = with pkgs; ''
                substituteInPlace tyt \
                  --replace jq ${jq}/bin/jq \
                  --replace mpv ${mpv}/bin/mpv \
                  --replace youtube-dl ${youtube-dl}/bin/youtube-dl
              '';

              installPhase = ''
                install -m 755 -D tyt $out/bin/tyt
              '';
            };

          defaultPackage = self.packages.${system}.tyt;

          # Development shell

          devShell = pkgs.mkShell {
            buildInputs = dependencies;
          };

        }

      );
}
