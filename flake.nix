{
  description = "Wiktionary-based dictionary files";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    niveum.url = "github:kmein/niveum";
  };

  outputs = {self, nixpkgs, niveum}: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        niveum.packages.${system}.stardict-tools
        pkgs.dict # dictzip
        pkgs.jq
      ];
    };
  };
}

