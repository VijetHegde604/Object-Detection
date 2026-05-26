{
  description = "Python + uv development shells (CPU default, CUDA optional)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
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
      ];

      mkDevShell = { cuda ? false }:
        pkgs.mkShell {
          packages = with pkgs;
            [
              python313
              uv
              stdenv.cc
              bashInteractive
              jupyter-all
            ]
            ++ pkgs.lib.optionals cuda [
              cudaPackages.cudatoolkit
              cudaPackages.cudnn
            ];

          shellHook =
            let
              baseLdPath = pkgs.lib.makeLibraryPath baseRuntimeLibs;
              cudaLdPath = pkgs.lib.makeLibraryPath [
                pkgs.cudaPackages.cudatoolkit
                pkgs.cudaPackages.cudnn
              ];
            in
            ''
              echo "================================================="
              echo "      Python Development Shell (uv + ${if cuda then "CUDA" else "CPU"})"
              echo "================================================="

              export LD_LIBRARY_PATH="${baseLdPath}:$LD_LIBRARY_PATH"

              ${if cuda then ''
                export LD_LIBRARY_PATH="${cudaLdPath}:$LD_LIBRARY_PATH"
                export CUDA_PATH="${pkgs.cudaPackages.cudatoolkit}"
                export CUDA_HOME="${pkgs.cudaPackages.cudatoolkit}"
                export CUDA_ROOT="${pkgs.cudaPackages.cudatoolkit}"
                export UV_TORCH_BACKEND="cu126"
                echo "CUDA shell enabled (use: nix develop .#cuda)."
              '' else ''
                export UV_TORCH_BACKEND="cpu"
                echo "CPU shell enabled (default)."
              ''}
            '';
        };
    in
    {
      devShells.${system}.default = mkDevShell { cuda = false; };
      devShells.${system}.cuda = mkDevShell { cuda = true; };
    };
}
