#!/bin/sh
# EffectZ Nightly handoff for the Arch packager: the hidden binary is the real GUI, and this
# launcher gives it the Nightly profile. The Nightly build refuses EFFECTZ_CONFIG_DIR, so the
# profile is passed as the Launcher's own protocol; a version query (or an already selected
# profile) passes through, because after `--` both would be file names.
set -eu

real_bin="$(dirname "$0")/.effectz-nightly/effectz"
case "${1:-}" in
  --version|-V|--launch-profile) exec "$real_bin" "$@" ;;
esac
profile_base="${XDG_DATA_HOME:-${HOME:?HOME is required}/.local/share}"
exec "$real_bin" --launch-profile nightly-v1 --profile-root "$profile_base/effectz-nightly" -- "$@"
