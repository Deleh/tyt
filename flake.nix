{
  description = "Play YouTube videos from the command line in a convenient way";

  outputs = { self, nixpkgs }: {

    defaultPackage.x86_64-linux =
      with import nixpkgs { system = "x86_64-linux"; };

      stdenv.mkDerivation {

        name = "tyt";
        src = self;

        buildInputs = [
          jq
          mpv
          youtube-dl
        ];

        patchPhase = ''
          substituteInPlace tyt \
            --replace jq ${jq}/bin/jq \
            --replace mpv ${mpv}/bin/mpv \
            --replace youtube-dl ${youtube-dl}/bin/youtube-dl
        '';
  
        installPhase = ''
          install -m 755 -D tyt $out/bin/tyt
        '';
      };

  };
}
