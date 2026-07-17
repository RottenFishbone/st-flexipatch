{
  description = "st-rottenpatch — suckless st with sixel + ligatures patches";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs }:
    let
      eachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    in
    {
      packages = eachSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          fontName = "Iosevka Nerd Font Mono:size=12";
        in
        {
          default = pkgs.stdenv.mkDerivation {
            pname = "st-rottenpatch";
            version = "0.9";

            src = ./.;

            nativeBuildInputs = with pkgs; [
              pkg-config
              ncurses  # for tic during install
            ];

            buildInputs = with pkgs; [
              libX11
              libXft
              fontconfig
              harfbuzz
              freetype
            ];

            buildPhase = ''
              runHook preBuild
              substituteInPlace config.h \
                --replace-quiet "Iosevka Nerd Font Mono:size=12" "${fontName}" \
                || true
              make
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p $out/bin
              cp st $out/bin/
              mkdir -p $out/share/applications
              cp st.desktop $out/share/applications/
              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "st (simple terminal) with sixel + ligatures patches";
              homepage = "https://github.com/rottenfishbone/st-flexipatch";
              license = licenses.mit;
              platforms = platforms.linux;
              mainProgram = "st";
            };
          };

          st-rottenpatch = self.packages.${system}.default;
        }
      );

      devShells = eachSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          default = pkgs.mkShell {
            name = "st-rottenpatch-dev";
            inputsFrom = [ self.packages.${system}.default ];
          };
        }
      );
    };
}
