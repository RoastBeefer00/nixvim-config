{
  description = "Nix/Nixvim implementation for Jake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    tree-sitter-rstml.url = "github:rayliwell/tree-sitter-rstml/flake";
  };

  outputs =
    {
      nixpkgs,
      nixvim,
      flake-parts,
      tree-sitter-rstml,
      ...
    }@inputs:
    flake-parts.lib.mkFlake
      {
        inherit inputs;
      }
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ];

        perSystem =
          {
            pkgs,
            system,
            config,
            ...
          }:
          let
            nixvimLib = nixvim.lib.${system};
            nixvim' = nixvim.legacyPackages.${system};
            # Use makeNixvimWithModule for proper module support
            nixvimModule = {
              pkgs = import nixpkgs {
                inherit system;
                config.allowUnfree = true;
              };
              module = {
                imports = [
                  ./config
                  tree-sitter-rstml.nixvimModule
                ];
              };
              extraSpecialArgs = { };
            };
            nvim = nixvim'.makeNixvimWithModule nixvimModule;
          in
          {
            packages.default = nvim;
            apps.default = {
              type = "app";
              program = "${nvim}/bin/nvim";
            };

            # Optional: Add checks back if you want CI validation
            checks.default = nixvimLib.check.mkTestDerivationFromNixvimModule nixvimModule;

            # Optional: Add formatter
            formatter = pkgs.alejandra;
          };

        flake = {
          nixosModules.default =
            {
              config,
              pkgs,
              lib,
              ...
            }:
            {
              imports = [ inputs.nixvim.nixosModules.nixvim ];
              programs.nixvim = import ./default.nix { inherit pkgs lib config; };
            };

          homeManagerModules.default =
            {
              config,
              pkgs,
              lib,
              ...
            }:
            {
              imports = [ inputs.nixvim.homeManagerModules.nixvim ];
              programs.nixvim = import ./default.nix { inherit pkgs lib config; };
            };

          darwinModules.default =
            {
              config,
              pkgs,
              lib,
              ...
            }:
            {
              imports = [ inputs.nixvim.darwinModules.nixvim ];
              programs.nixvim = import ./default.nix { inherit pkgs lib config; };
            };
        };
      };
}
