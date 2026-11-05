{
  description = "Wiktionary-based dictionary files";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
  };

  outputs = inputs: {
    devShells = builtins.mapAttrs (system: pkgs: {
      default = pkgs.mkShell {
        packages = [
          pkgs.curl
          pkgs.dict # dictzip, which pyglossary shells out to
          pkgs.jq
          pkgs.pyglossary
          pkgs.zip
        ];
      };
    }) inputs.nixpkgs.legacyPackages;
  };
}
