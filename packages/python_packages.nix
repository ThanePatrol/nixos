{ pkgs }:

let
  python = pkgs.python3;
  pythonPackages = python.pkgs;

in
python.withPackages (ps: with ps; [
  numpy
  scipy
  pandas
  matplotlib
  requests
])
