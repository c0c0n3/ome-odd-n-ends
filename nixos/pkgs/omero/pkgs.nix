#
# All the packages required to run OMERO apps: blitz, web, cli, etc.
# This attribute set is the only place where we should keep packages
# for OMERO so to make it easy to change and track them. In fact,
# this is where we select package versions that are compatible with
# a given OMERO release---5.4.8 currently.
#
{ pkgs, lib, pykgs, omero-runtime-deps, wrap-utils }:  # 17.03  NOTE (1)

with lib;
let
  jdk = pkgs.jdk;               # openjdk-8u121b13
  jre = pkgs.jre;               # openjre-8u131b11
  server = pkgs.callPackage ./server.nix {
    inherit wrap-utils omero-runtime-deps; };
  smuggler = pkgs.callPackage ./smuggler.nix { inherit jre; };
in
assert hasPrefix "17.03" nixpkgsVersion;
assert pykgs.zeroc-ice-py.version == pkgs.zeroc_ice.version;
assert pykgs.omero-py.release == server.release;  # NOTE (2)
{
  inherit jdk jre;
  mencoder = pkgs.mplayer;      # 1.3.0             NOTE (3)
  postgres = pkgs.postgresql;   # 9.5.6
  inherit server smuggler;
  zeroc_ice = pkgs.zeroc_ice;   # 3.6.3
}
// pykgs

# Notes
# -----
# 1. Version Numbers. The version numbers noted next to each package name
# refer to the packages in NixOS 17.03. Version numbers for Python packages
# are noted in `python/default.nix`.
#
# 2. OmeroPy Duplication. OMERO.server comes with a copy of OmeroPy in its
# `lib/python` directory which `bin/omero` adds to its PYTHONPATH when you
# run it. We make sure the two Python libs are the same to avoid runtime
# issues.
#
# 3. MEncoder. Movie Maker (OMERO.scripts) needs `mencoder` but NixOS doesn't
# package it separately from MPlayer.
#
