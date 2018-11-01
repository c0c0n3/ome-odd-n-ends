#
# Puts together all our custom packages.
#
{ ... }:

with import ./pkgs-from-json.nix { json = ./nixos-17-03.json; };

rec {

  pykgs = callPackage ./python {};
  omero = callPackage ./omero { inherit pykgs; };

}
