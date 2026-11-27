#!/usr/bin/env bash
# Stage the EffectZ Nightly-only handoff for the Arch packager.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
source_tree="$1"
work="$2"
destination="$3"
basename="$4"
stage="$work/$basename"

mkdir -p "$work"
cp -R "$source_tree" "$stage"
mkdir "$stage/bin/.effectz-nightly"
mv "$stage/bin/effectz" "$stage/bin/.effectz-nightly/effectz"
cp "$here/nightly-arch-launch.sh" "$stage/bin/effectz"
chmod 755 "$stage/bin/effectz"
tar -C "$work" -czf "$destination/$basename.tar.gz" "$basename"
echo "wrote $destination/$basename.tar.gz"
