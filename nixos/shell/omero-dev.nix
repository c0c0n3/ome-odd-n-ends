#
# Nix expression to set up an OMERO dev environment for the latest OMERO
# release in our Nix packages.
# You can use this environment both to build and run OMERO apps from the
# command line.
# Usage:
#
#     $ nix-shell omero-dev.nix
#
with import ../pkgs/pkgs-from-json.nix { json = ../pkgs/nixos-17-03.json; };
with import ./util.nix;
with import ../pkgs { inherit pkgs lib; };

let
  shell-name = "omero-dev";
  zeroc_ice = omero.packages.zeroc_ice;
in
runCommand "dummy"
{

  buildInputs = omero.deps.dev;

  shellHook = setShellHook { inherit shell-name zeroc_ice; };

} ""
