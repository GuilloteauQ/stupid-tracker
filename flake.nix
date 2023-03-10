{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/22.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      OUTFILE = ".time_tracker.csv";
      myRPackages = with pkgs.rPackages; [
        tidyverse
      ];
      myR = pkgs.rWrapper.override { packages = myRPackages; };
    in
    {
      packages.${system} = rec {
        default = tracker;
        tracker = pkgs.writeScriptBin "sput" ''
          #!${pkgs.bash}/bin/bash
          if [[ $# -eq 1 ]]
          then
            case $1 in
              stop|start)
                echo "$1, $(date +%s)" >> ${OUTFILE}
                ;;
              *)
                echo "Oops wrong args $1"
                ;;
            esac
          else
              echo "Oops wrong args $1"
          fi
        '';
        plot = pkgs.writeScriptBin "show" ''
          ${myR}/bin/Rscript ${./script.R} ${OUTFILE}
        '';
      };
      
      devShells.${system} = {
        r-shell = pkgs.mkShell {
          buildInputs = [ myR ];
        };
      };
    };
}
