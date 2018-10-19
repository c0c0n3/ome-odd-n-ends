#
# OMERO Marshal package.
# This package is the Nixified version of OME's official Python package:
# - https://pypi.python.org/pypi/omero-marshal/0.5.1
#
# This Nix package works with Python 2.7 but not 2.6. Might work with
# Python 3 too, but I haven't tested it.
#
{ # lib imports
  fetchurl, lib, buildPythonPackage,
  # package dependencies
  omero-py
}:

with lib;

buildPythonPackage rec {

  name = "omero-marshal-${version}";
  version = "0.5.3";
  meta = {
    homepage = "https://github.com/openmicroscopy/omero-marshal";
    description = ''
      Extensible marshaling code to transform various OMERO objects into
      dictionaries which can then be marshalled using JSON or alternative
      encodings.
    '';
    license = licenses.gpl2;
    platforms = platforms.unix;
  };

  src = let
    pname = "omero_marshal";
    file = "${pname}-${version}.tar.gz";
  in
  fetchurl {
    url = "mirror://pypi/${substring 0 1 pname}/${pname}/${file}";
    sha256 = "0vwr7v2dzyh7vgacpg6dcq9lzxi3n0v3dh10x7v1yjyzcnmyi0kv";
  };

  propagatedBuildInputs = [ omero-py ];  # NOTE (1)

  # NOTE (2)
  prePatch = ''
    substituteInPlace requirements.txt --replace "importlib>=1.0.1" ""
  '';

  doCheck = false;  # NOTE (3)

}
# Notes
# -----
# 1. OmeroPy Dependency. `omero-marshal` has runtime dependencies both on
# OmeroPy and the ICE Python bindings. This is why we list `omero-py` in
# `propagatedBuildInputs`---in turn, `omero-py` adds ICE, so we get both.
# Then when you add `omero-marshal` to your Python environment (e.g. using
# `withPackages`), you'll get all three packages. Happiness? Yes, unless
# you want to use the same Python environment to run `bin/omero` from the
# OMERO.server package which already contains all of OmeroPy (in `lib/python`).
# Now `bin/omero` automatically adds its `lib/python` to the PYTHONPATH,
# so you have to make sure the OmeroPy that `omero-marshal` brings in is
# the same as the one in OMERO.server's `lib/python`.
#
# 2. importlib. Back-port of Python 3 import functionality but it only works
# with Python 2.6 not with 2.7. For the moment I'm only using Python 2.7, so
# can safely zap the dependency. Anyhoo, the OMERO guys are likely to make it
# conditional, e.g.
#
#     importlib>=1.0.1; python_version=='2.6'
#
# When that happens, get rid of `prePatch` above.
# See:
# - https://pip.pypa.io/en/stable/reference/pip_install/#requirement-specifiers
#
# 3. Tests. Can't get them to work. Even after adding `omero-py` and `pytest`
# to my `buildInputs`, I still get a "no tests ran" message and the build
# fails. Not sure what the hell is going on here, so I'm disabling the running
# of the test suite for the moment...
#
