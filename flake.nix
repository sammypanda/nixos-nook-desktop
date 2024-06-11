{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    systems.url = "github:nix-systems/default-linux";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, systems, ... }:
  let
    eachSystem = nixpkgs.lib.genAttrs (import systems);
  in {
    packages = eachSystem (system:
    let
      pkgs = import nixpkgs {
        system = "${system}";
      };
    in {
      default = self.packages.${system}.nook-desktop;
      nook-desktop = pkgs.callPackage ./pkgs/nook-desktop/default.nix {};
    });
  };
}