#!/usr/bin/env sh
# Puts a piaf release (detector, classifier, manifest) in assets/models/.
# The .tflite files are not in Git: they come from the team's DVC storage
# (gs://piaf-hesso-machledata-dvc), so this needs access to github.com/swaiku/piaf
# and a Google account on the piaf-hesso-machledata project.
#
#   tool/fetch_models.sh [version] [piaf revision]
#
# shortcut: fetched at build time; the app downloads releases from pigeon-api
# (GET /models/latest) once P3 serves them.
set -eu
version=${1:-0.1.0}
rev=${2:-3a072a4} # piaf commit that locked this release in DVC
out=$(dirname "$0")/../assets/models
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
uvx --from 'dvc[gs]' dvc get git@github.com:swaiku/piaf.git \
  "modelling/outputs/release/$version" --rev "$rev" -o "$tmp/release"
cp "$tmp/release/detector.tflite" "$tmp/release/classifier.tflite" \
  "$tmp/release/manifest.json" "$out/"
echo "Release $version in $out"
