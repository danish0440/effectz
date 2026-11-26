#!/usr/bin/env bash
# Validate the staged Arch launcher without building or opening EffectZ.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
stage="$work/source"
dst="$work/dist"
base=effectz-0.0.1-nightly.1-linux-x86_64
mkdir -p "$stage/bin" "$dst" "$work/extract"

# A local argv recorder stands in for the compiled binaries. It never opens a UI.
cat >"$stage/bin/effectz" <<'RECORDER'
#!/bin/sh
printf '<%s>\n' "$@"
RECORDER
chmod 755 "$stage/bin/effectz"
cp "$stage/bin/effectz" "$stage/bin/effectz-cli"

bash "$HERE/nightly-arch-tar.sh" "$stage" "$work/stage" "$dst" "$base"
tar -xzf "$dst/$base.tar.gz" -C "$work/extract"
bin="$work/extract/$base/bin"
# Simulate the existing Arch bin-tree copy and public launcher rename.
mkdir -p "$work/installed"
cp -R "$bin" "$work/installed/bin"
bin="$work/installed/bin"
mv "$bin/effectz" "$bin/effectz-nightly"
mv "$bin/effectz-cli" "$bin/effectz-nightly-cli"

[[ ! -e "$stage/bin/.effectz-nightly" ]]
cmp "$stage/bin/effectz" "$bin/.effectz-nightly/effectz"
cmp "$stage/bin/effectz-cli" "$bin/effectz-nightly-cli"
# The launcher must start the hidden GUI through the Nightly profile; the profile base is fixed
# here so the recorded arguments are exactly comparable.
export XDG_DATA_HOME="$work/xdg-data"
profile() {
  printf '<%s>\n' --launch-profile nightly-v1 --profile-root "$XDG_DATA_HOME/effectz-nightly" -- "$@"
}
expect() {
  expected="$1"
  shift
  actual=$(PATH="$bin:$PATH" effectz-nightly "$@")
  if [[ "$actual" != "$expected" ]]; then
    printf 'expected:\n%s\nactual:\n%s\n' "$expected" "$actual" >&2
    exit 1
  fi
}
expect "$(profile)"
expect "$(profile 'project with spaces.ec' '--other-name.ec')" \
  'project with spaces.ec' '--other-name.ec'
# A version query and an already selected profile pass through unchanged: after `--` both are files.
expect '<--version>' --version
expect '<-V>' -V
expect "$(printf '<%s>\n' --launch-profile nightly-v1 --profile-root "$work/launcher-root" --version)" \
  --launch-profile nightly-v1 --profile-root "$work/launcher-root" --version

echo "PASS: Arch Nightly handoff starts the hidden GUI through the Nightly launch profile"
