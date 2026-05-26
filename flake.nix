{
  description = "Python + uv dev shell with optional CUDA support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          cudaSupport = true;
        };
      };

      # Core runtime libs often required by Python wheels.
      baseRuntimeLibs = with pkgs; [
        stdenv.cc.cc.lib
        glib
        libGL
        zlib
      ];

      # CUDA runtime pieces; safe to keep available even when not used.
      cudaRuntimeLibs = with pkgs; [
        cudaPackages.cudatoolkit
        cudaPackages.cudnn
      ];

      # Toggle CUDA at shell startup:
      #   USE_CUDA=1 nix develop
      # Default is CPU-only behavior.
      useCuda = ''${USE_CUDA:-0}'';
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          python313
          uv
          stdenv.cc
          bashInteractive
          jupyter-all
        ];

        shellHook = ''
          echo "================================================="
          echo "    Python Development Shell (uv + optional CUDA)"
          echo "================================================="

          BASE_LD_PATH="${pkgs.lib.makeLibraryPath baseRuntimeLibs}"
          CUDA_LD_PATH="${pkgs.lib.makeLibraryPath cudaRuntimeLibs}"

          if [ "${useCuda}" = "1" ]; then
            export LD_LIBRARY_PATH="$BASE_LD_PATH:$CUDA_LD_PATH:$LD_LIBRARY_PATH"
            export CUDA_PATH="${pkgs.cudaPackages.cudatoolkit}"
            export CUDA_HOME="${pkgs.cudaPackages.cudatoolkit}"
            export CUDA_ROOT="${pkgs.cudaPackages.cudatoolkit}"
            export UV_TORCH_BACKEND="cu126"
            echo "CUDA mode enabled (USE_CUDA=1)."
          else
            export LD_LIBRARY_PATH="$BASE_LD_PATH:$LD_LIBRARY_PATH"
            export UV_TORCH_BACKEND="cpu"
            echo "CPU mode enabled (default). Set USE_CUDA=1 to enable CUDA runtime paths."
          fi
        '';
      };
    };
}
