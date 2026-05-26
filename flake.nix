{
  description = "Python + uv development shells (CPU default, CUDA optional)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          cudaSupport = true;
        };
      };

      baseRuntimeLibs = with pkgs; [
        stdenv.cc.cc.lib
        glib
        libGL
        zlib

        # Rendering libraries for OpenCV
        libxcb
        libx11
        libxext
        libxrender
        libxau
        libxdmcp
      ];

      mkDevShell =
        {
          cuda ? false,
        }:
        pkgs.mkShell {
          packages =
            with pkgs;
            [
              python313
              uv
              stdenv.cc
              bashInteractive

              # Jupyter
              python313Packages.jupyterlab
              python313Packages.notebook
              python313Packages.ipykernel
            ]
            ++ pkgs.lib.optionals cuda [
              cudaPackages.cuda_nvcc
              cudaPackages.cudnn
            ];

          shellHook =
            let
              baseLdPath = pkgs.lib.makeLibraryPath baseRuntimeLibs;
              cudaLdPath = pkgs.lib.makeLibraryPath [
                pkgs.cudaPackages.cuda_nvcc
                pkgs.cudaPackages.cudnn
              ];
            in
            ''
              echo "================================================="
              echo "     Python Development Shell (uv + ${if cuda then "CUDA" else "CPU"})"
              echo "================================================="

              export LD_LIBRARY_PATH="${baseLdPath}:$LD_LIBRARY_PATH"

              ${
                if cuda then
                  ''
                    export LD_LIBRARY_PATH="${cudaLdPath}:$LD_LIBRARY_PATH"
                    export CUDA_PATH="${pkgs.cudaPackages.cuda_nvcc}"
                    export CUDA_HOME="${pkgs.cudaPackages.cuda_nvcc}"
                    export CUDA_ROOT="${pkgs.cudaPackages.cuda_nvcc}"
                    export UV_TORCH_BACKEND="cu126"
                    echo "CUDA shell enabled (use: nix develop .#cuda)."
                  ''
                else
                  ''
                    export UV_TORCH_BACKEND="cpu"
                    echo "CPU shell enabled (default)."
                  ''
              }
            '';
        };
    in
    {

      devShells.${system} = {
        default = mkDevShell { cuda = false; };
        cuda = mkDevShell { cuda = true; };
      };
    };
}
