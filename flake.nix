{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
    systems = {
      url = "github:nix-systems/default";
    };
  };

  outputs = { nixpkgs, flake-parts, systems, ... } @ inputs:
    let
      mkPkgs = system:
        import nixpkgs {
          inherit system;
        };
    in
      flake-parts.lib.mkFlake { inherit inputs; } {
        systems = import systems;
        
        perSystem = { system, config, ... }: let
          pkgs = mkPkgs system;
        in {

          packages.default = pkgs.rustPlatform.buildRustPackage {
            pname = "image-hct";
            version = "0.1.0";
            src = pkgs.lib.cleanSource ./.;
            cargoLock.lockFile = ./Cargo.lock;
          };
          
          # Development shell
          devShells.default = pkgs.mkShell {
            inputsFrom = [ config.packages.default ];
            buildInputs = with pkgs; [
              rust-bin.stable.latest.default
              rust-analyzer
              rustfmt
              clippy
            ];
          };
        };
      };
}

