#
# OMERO 5.4 database bootstrap package for NixOS 17.03.
# Installs a `omero-bootstrap-db` command to bootstrap the OMERO database
# as documented in `db-boostrap.py`.
#
# NOTE. This package works just as well for an OMERO 5.3 database.
#
{ # lib imports
  stdenv, wrap-utils,
  # package dependencies from our OMERO packages
  postgres, omero-server, pyenv
}:

with wrap-utils;

let
  exec-name = "omero-bootstrap-db";
  db-bootstrap-wrapper = src:
    makePgmWrapper {
      name = exec-name;
      runtime-deps = [ postgres omero-server (pyenv []) ];
      pgm = [ "python" src ];
    };
in
stdenv.mkDerivation rec {

  name = "OMERO.db-bootstrap-${version}";
  release = omero-server.release;
  version = omero-server.version;
  meta = {
    homepage = omero-server.meta.homepage;
    description = ''
      Database bootstrap scripts for OMERO.server.
    '';
    license = omero-server.meta.license;
  };

  src = ./db-bootstrap.py;

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    ln -s ${db-bootstrap-wrapper src} $out/bin/${exec-name}
  '';

}
