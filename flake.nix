{
  description = "Play YouTube videos from the command line in a convenient way";

  nixConfig.bash-prompt = "\[\\e[1m\\e[31mtyt-develop\\e[0m\]$ ";

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

        in
        {

          # Package

          packages.tyt =

            pkgs.stdenv.mkDerivation {

              name = "tyt";
              src = self;

              patchPhase = with pkgs; ''
                substituteInPlace tyt \
                  --replace jq ${pkgs.jq}/bin/jq \
                  --replace mpv ${mpv}/bin/mpv \
                  --replace youtube-dl ${pkgs.youtube-dl}/bin/youtube-dl
              '';

              installPhase = ''
                install -m 755 -D tyt $out/bin/tyt
              '';
            };

          defaultPackage = self.packages.${system}.tyt;

          # Development shell

          devShell = pkgs.mkShell {
            buildInputs = [
              pkgs.jq
              mpv
              pkgs.youtube-dl
            ];
          };

        }

      );
}
