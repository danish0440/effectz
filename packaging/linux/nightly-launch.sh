#!/bin/sh
# The launcher inside EffectZ Nightly's flat tar: an unpacked copy is isolated like the
# packages, so it never falls back to the stable settings folder. The GUI itself is `effectz-bin`;
# `effectz` is the name people run, and the version query still answers from it.
set -eu

here="$(dirname "$0")"
real_bin="$here/effectz-bin"
case "${1:-}" in
  --version|-V|--launch-profile) exec "$real_bin" "$@" ;;
esac
profile_base="${XDG_DATA_HOME:-${HOME:?HOME is required}/.local/share}"
exec "$real_bin" --launch-profile nightly-v1 --profile-root "$profile_base/effectz-nightly" -- "$@"
