{ pkgs }:

let
  python = pkgs.python3;

in
python.withPackages (ps: with ps; [
  numpy
  scipy
  pandas
  matplotlib
  requests
])
