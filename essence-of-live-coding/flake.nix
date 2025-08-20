{
  inputs =
    {
      nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    };

  outputs = { self, nixpkgs, nixpkgs-unstable }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux.pkgs;
      pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux.pkgs;

      native-build-libs = with pkgs; [
        # https://discourse.nixos.org/t/pkg-config-cant-find-gobject/38519/3
        pkg-config
      ];

      build-libs = with pkgs; [
        hpack

        # Liquid haskell
        z3

        zlib
        # pkgs.haskell.compiler.ghc88
        # haskell.compiler.ghc910
        # haskell.compiler.ghc98
        haskell.compiler.ghc98

        # (pkgs-unstable.haskell-language-server.override { supportedGhcVersions = [ "982" ]; })
        pkgs-unstable.cabal-install
      ];

      # Many are excluded from here. Building runtime libms from the system version of nix is superior.
      runtimeLibs = with pkgs; [
        msmtp

        SDL2
        xorg.libXext
        libGLU
        libGL
        xorg.libX11
        xorg.libXi
        xorg.libXrandr
        xorg.libXxf86vm
        xorg.libXcursor
        xorg.libXinerama
      ];
      all-libs = runtimeLibs ++ build-libs;
      # all-library-path = "${pkgs.lib.makeLibraryPath all-libs}";
    in {
      devShells.x86_64-linux.default = pkgs.mkShell {
        nativeBuildInputs = native-build-libs;
        buildInputs = all-libs;

        # Not needed
        #   export PKG_CONFIG_PATH=${pkgs.SDL2}/lib/pkgconfig
        #   export C_INCLUDE_PATH=${pkgs.SDL2.dev}/include
        #   export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${all-library-path}"
        #   export LIBRARY_PATH="${all-library-path}"
        shellHook = ''
          export VK_LOADER_DEBUG="all"
        '';
      };

      # Build option for email not needed currently
      # devShells.x86_64-linux.buildEmailScheduler = pkgs.mkShell {
      #   buildInputs = build-libs;
      # };
    };
}
