#
# Expression to pin Nix packages to a specific version taken from a JSON
# file generated with `nix-prefetch-git`.
# Lifted from:
# - https://cah6.github.io/technology/nix-haskell-1/
# See also:
# - https://github.com/Gabriel439/haskell-nix/blob/master/project0/README.md
{
  bootstrap ? import <nixpkgs> {}
, json
}:
let
  nixpkgs = builtins.fromJSON (builtins.readFile json);
  src = bootstrap.fetchFromGitHub {
    owner = "NixOS";
    repo  = "nixpkgs-channels";
    inherit (nixpkgs) rev sha256;
  };
in
  import src {}
