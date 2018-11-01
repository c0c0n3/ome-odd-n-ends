#
# OMERO 5.4 package for NixOS 17.03.
# This package installs a wrapper script that will unzip the OMERO
# server bundle on its first run and call `omero` on each subsequent
# run. The server bundle is unzipped into the specified `omero-root`
# directory and permissions are changed recursively on its contents
# to make them owned by the specified `omero-user` and `omero-group`.
#
# Note that there's no garbage collection of the unzipped OMERO bundle,
# after uninstalling this package you'll have to delete the OMERO server
# directory yourself.
#
# NOTE (1) (2)
#
{ # lib imports
  stdenv, fetchurl, lib, wrap-utils,
  # package dependencies (unzip is needed for the wrapper, see below)
  unzip, omero-runtime-deps,
  # package configuration
  omero-root ? "/var/lib",  # there's no /opt by default in NixOS
  omero-user ? "omero",
  omero-group ? "omero"
}:

with lib;
with wrap-utils;

let
  omero-wrapper = pkg-name: pkg-src:
    makeScript { name = "omero-wrapper"; runtime-deps = omero-runtime-deps; }
    ''
      if [ -d '${omero-root}/${pkg-name}' ];
      then
        ${execWithArgs ["${omero-root}/${pkg-name}/bin/omero"]}
      else
        echo Setting up OMERO...

        cd '${omero-root}'
        ${unzip}/bin/unzip '${pkg-src}' > /dev/null
        chown -R ${omero-user}:${omero-group} '${pkg-name}'

        echo ...done! Rerun the omero command now.
      fi
    '';
in
stdenv.mkDerivation rec {

  name = "OMERO.server-${version}";
  release = "5.4.9";
  version = "${release}-ice36-b101";
  meta = {
    homepage = "https://www.openmicroscopy.org/";
    description = ''
      OMERO.server is server software for visualization, management and
      analysis of biological microscope images.
    '';
    license = licenses.gpl2;
  };

  src = fetchurl {
    url = "http://downloads.openmicroscopy.org/omero/" +
          "${release}/artifacts/${name}.zip";
    sha256 = "0853adxhwgfkwk38xbsww3x687c694vkpxvir4b0fiihlnpa21kn";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    ln -s ${omero-wrapper name src} $out/bin/omero
  '';

}
# Notes
# -----
# 1. Running `omero`. Why not just unzip the OMERO.server bundle in the Nix
# store, like any other package? The problem is that `omero` will only run
# if the whole release zip file is unzipped in a directory with read and
# write access. But the whole Nix store is read-only. I should figure out a
# way to tell `omero` to use different data directories so that we could have
# a proper Nix package. But for the moment, the best I could do is to let
# the user decide where to unpack the server bundle and make sure the `omero`
# command ends up in the PATH through the wrapper script.
#
# 2. Garbage Collection. There's probably a way to do it, e.g. storing the
# package hash in the unzipped server directory and having a service that
# checks if that hash is still in the Nix store. But I'm not wasting my time
# on this as a better option is to separate code from data (see point 1 above)
# and keep all the code in the Nix store which can then be garbage-collected.
#
