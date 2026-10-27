#!/usr/bin/env bash
# Prints the UDID of the simulator to use for build/test/run.
# Picks SIM_NAME on the newest installed runtime of iOS SIM_OS (a major version; empty = any).
# The default is pinned so local runs and CI test on the same device and OS (#23). iPhone 17 on
# iOS 26 is lighter on the Mac than the newest device and runtime (#38). If that runtime has no
# such device yet (fresh machine, CI), the device is created there.
set -euo pipefail

SIM_NAME="${SIM_NAME:-iPhone 17}"
SIM_OS="${SIM_OS-26}"

# Only runtimes that support the device (some devices ship with a runtime of their own).
runtime=$(xcrun simctl list runtimes available -j | jq -r --arg os "$SIM_OS" --arg name "$SIM_NAME" '
  .runtimes
  | map(select(.platform == "iOS" and ($os == "" or (.version | split(".")[0]) == $os)))
  | map(select(any(.supportedDeviceTypes[]?; .name == $name)))
  | max_by(.version | split(".") | map(tonumber))
  | .identifier // empty
')
[[ -n "$runtime" ]] || { echo "No iOS ${SIM_OS:-any} simulator runtime with \"$SIM_NAME\" installed" >&2; exit 1; }

udid=$(xcrun simctl list devices available -j | jq -r --arg rt "$runtime" --arg name "$SIM_NAME" \
  '.devices[$rt] // [] | map(select(.name == $name)) | first | .udid // empty')
if [[ -n "$udid" ]]; then
  echo "$udid"
  exit 0
fi

type=$(xcrun simctl list devicetypes -j | jq -r --arg name "$SIM_NAME" \
  '.devicetypes | map(select(.name == $name)) | first | .identifier // empty')
[[ -n "$type" ]] || { echo "Unknown simulator device type \"$SIM_NAME\"" >&2; exit 1; }
xcrun simctl create "$SIM_NAME" "$type" "$runtime"
