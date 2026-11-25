#!/usr/bin/env bash
# Validate the launcher inside the flat Nightly tar without building or opening EffectZ.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
stage="$work/unpacked"
mkdir -p "$stage"

# A local argv recorder stands in for the compiled GUI, which the launcher starts as `effectz-bin`.
cat >"$stage/effectz-bin" <<'RECORDER'
#!/bin/sh
printf '<%s>\n' "$@"
RECORDER
chmod 755 "$stage/effectz-bin"
cp "$HERE/nightly-launch.sh" "$stage/effectz"
chmod 755 "$stage/effectz"

# A fixed profile base keeps the recorded arguments exactly comparable.
export XDG_DATA_HOME="$work/xdg-data"
profile() {
  printf '<%s>\n' --launch-profile nightly-v1 --profile-root "$XDG_DATA_HOME/effectz-nightly" -- "$@"
}
expect() {
  expected="$1"
  shift
  actual=$("$stage/effectz" "$@")
  if [[ "$actual" != "$expected" ]]; then
    printf 'expected:\n%s\nactual:\n%s\n' "$expected" "$actual" >&2
    exit 1
  fi
}
expect "$(profile)"
expect "$(profile 'project with spaces.ec' '--other-name.ec')" 'project with spaces.ec' '--other-name.ec'
# A version query and an already selected profile pass through: after `--` both would be files.
expect '<--version>' --version
expect '<-V>' -V
expect "$(printf '<%s>\n' --launch-profile nightly-v1 --profile-root "$work/launcher-root" --version)" \
  --launch-profile nightly-v1 --profile-root "$work/launcher-root" --version
# HOME is the only other base, and the profile root is never optional.
home_run=$(env -u XDG_DATA_HOME HOME="$work/home" "$stage/effectz")
expected_home=$(printf '<%s>\n' --launch-profile nightly-v1 --profile-root "$work/home/.local/share/effectz-nightly" --)
if [[ "$home_run" != "$expected_home" ]]; then
  printf 'expected:\n%s\nactual:\n%s\n' "$expected_home" "$home_run" >&2
  exit 1
fi
if env -u XDG_DATA_HOME -u HOME "$stage/effectz" >/dev/null 2>&1; then
  echo 'a launcher without HOME must refuse rather than start with the stable profile' >&2
  exit 1
fi

echo "PASS: the flat Nightly tar's launcher starts the GUI through the Nightly launch profile"
