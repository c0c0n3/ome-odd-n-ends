#
# Nix expression to set up an OMERO build environment for the latest OMERO
# release in our Nix packages.
# You can only use this environment to build the OMERO components with the
# `build.py` script. If you also need to run OMERO apps as you develop, use
# `omero-dev.nix` instead.
# Usage:
#
#     $ nix-shell omero-build.nix
#
with import ../pkgs/pkgs-from-json.nix { json = ../pkgs/nixos-17-03.json; };
with import ./util.nix;
with import ../pkgs { inherit pkgs lib; };

let
  shell-name = "omero-build";
  zeroc_ice = omero.packages.zeroc_ice;
in
runCommand "dummy"
{

  buildInputs = omero.deps.build;

  shellHook = setShellHook { inherit shell-name zeroc_ice; };

} ""
