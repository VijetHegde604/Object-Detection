{
  description = "Python environment using uv and native toolchains";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      # Define all the native runtime libraries that Python wheels look for
      runtimeLibs = with pkgs; [
        stdenv.cc.cc.lib
        glib
        libGL
        zlib
      ];
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          python311
          uv
          stdenv.cc
          bashInteractive
        ];

        shellHook = ''
          echo "================================================="
          echo "       Python Development Shell        "
          echo "================================================="

          # Stitch together the LD_LIBRARY_PATH so downloaded wheels can find system libraries
          export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath runtimeLibs}:$LD_LIBRARY_PATH"

          # Create a virtual environment using uv if it doesn't exist
          if [ ! -d ".venv" ]; then
            echo "Creating virtual environment with uv..."
            uv venv
          fi

          # Activate the environment
          source .venv/bin/activate

          echo "Environment active"
        '';
      };
    };
}
