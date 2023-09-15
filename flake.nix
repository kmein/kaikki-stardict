{
  description = "Wiktionary-based dictionary files";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    niveum.url = "github:kmein/niveum";
  };

  outputs = {
    self,
    nixpkgs,
    niveum,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    lib = nixpkgs.lib;

    dumps = {
      chu = pkgs.fetchurl {
        url = "https://kaikki.org/dictionary/Old%20Church%20Slavonic/kaikki.org-dictionary-OldChurchSlavonic.json";
        hash = "sha256-Y8a05CQ6abSuOAuxMb081NF0TBfR17edP8HuHegu8as=";
      };
      hye = pkgs.fetchurl {
        url = "https://kaikki.org/dictionary/Old%20Armenian/kaikki.org-dictionary-OldArmenian.json";
      };
      goh = pkgs.fetchurl {
        url = "https://kaikki.org/dictionary/Old%20High%20German/kaikki.org-dictionary-OldHighGerman.json";
      };
      non = pkgs.fetchurl {
        url = "https://kaikki.org/dictionary/Old%20Norse/kaikki.org-dictionary-OldNorse.json";
        hash = "sha256-BQuRjxQihYuNT5hLJc9B5aoTvj157TV8UJdzShYWNHs=";
      };
      grc = pkgs.fetchurl {
        url = "https://kaikki.org/dictionary/Ancient%20Greek/kaikki.org-dictionary-AncientGreek.json";
      };
      enm = pkgs.fetchurl {
        url = "https://kaikki.org/dictionary/Middle%20English/kaikki.org-dictionary-MiddleEnglish.json";
      };
      ang = pkgs.fetchurl {
        url = "https://kaikki.org/dictionary/Old%20English/kaikki.org-dictionary-OldEnglish.json";
      };
      # https://kaikki.org/dictionary/Turkish/kaikki.org-dictionary-Turkish.json
      # https://kaikki.org/dictionary/Irish/kaikki.org-dictionary-Irish.json
        # https://kaikki.org/dictionary/Old%20Irish/kaikki.org-dictionary-OldIrish.json
        # https://kaikki.org/dictionary/Middle%20Irish/kaikki.org-dictionary-MiddleIrish.json
      # https://kaikki.org/dictionary/Armenian/kaikki.org-dictionary-Armenian.json
      # https://kaikki.org/dictionary/Lithuanian/kaikki.org-dictionary-Lithuanian.json
      # https://kaikki.org/dictionary/Gothic/kaikki.org-dictionary-Gothic.json
      # https://kaikki.org/dictionary/Arabic/kaikki.org-dictionary-Arabic.json
        # https://kaikki.org/dictionary/South%20Levantine%20Arabic/kaikki.org-dictionary-SouthLevantineArabic.json
      # https://kaikki.org/dictionary/Egyptian/kaikki.org-dictionary-Egyptian.json
    };

    babylon = languageName: pkgs.runCommand languageName {} ''
      ${pkgs.jq}/bin/jq --slurp --raw-output --from-file ${./generate-babylon.jq} ${dumps.${languageName}} > $out
    '';

    stardict-tools = niveum.packages.${system}.stardict-tools;

    stardict = languageName: pkgs.runCommand languageName {} ''
      mkdir $out
      cp ${babylon languageName} ${languageName}.babylon
      PATH=${lib.makeBinPath [stardict-tools pkgs.dict]} babylon ${languageName}.babylon
      mv ${languageName}.{idx,ifo,syn,dict.dz} $out
    '';
  in {
    packages.${system} = {
      raw-non = dumps.non;
      babylon-non = babylon "non";
      stardict-chu = stardict "chu"; # Old Church Slavonic
      stardict-hye = stardict "hye"; # Classical Armenian
      stardict-grc = stardict "grc"; # Ancient Greek
      stardict-ang = stardict "ang"; # Old English
      stardict-enm = stardict "enm"; # Middle English
      stardict-non = stardict "non"; # Old Norse
    };
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        stardict-tools
        pkgs.dict # dictzip
      ];
    };
  };
}

