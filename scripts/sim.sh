#!/usr/bin/env bash
# Prints the UDID of the simulator to use for build/test/run.
# Picks SIM_NAME on the newest runtime of iOS SIM_OS (a major version; empty = any). The default
# is pinned so local runs and CI test on the same device (#23). iPhone 17 on iOS 26 is lighter on
# the Mac than the newest device and runtime (#38). If the runtime is installed but has no such
# device yet (fresh machine, CI), the device is created.
set -euo pipefail

SIM_NAME="${SIM_NAME:-iPhone 17}"
SIM_OS="${SIM_OS-26}"

# Matching iOS runtimes, newest first: "<identifier> <version>".
runtimes=$(xcrun simctl list runtimes available -j | jq -r --arg os "$SIM_OS" '
  .runtimes
  | map(select(.platform == "iOS" and ($os == "" or (.version | split(".")[0]) == $os)))
  | sort_by(.version | split(".") | map(tonumber))
  | reverse
  | .[]
  | "\(.identifier) \(.version)"
')
[[ -n "$runtimes" ]] || { echo "No iOS ${SIM_OS:-any} simulator runtime installed" >&2; exit 1; }

devices=$(xcrun simctl list devices available -j)
while read -r runtime _; do
  udid=$(jq -r --arg rt "$runtime" --arg name "$SIM_NAME" \
    '.devices[$rt] // [] | map(select(.name == $name)) | first | .udid // empty' <<<"$devices")
  if [[ -n "$udid" ]]; then
    echo "$udid"
    exit 0
  fi
done <<<"$runtimes"

newest=$(head -1 <<<"$runtimes" | cut -d' ' -f1)
type=$(xcrun simctl list devicetypes -j | jq -r --arg name "$SIM_NAME" \
  '.devicetypes | map(select(.name == $name)) | first | .identifier // empty')
[[ -n "$type" ]] || { echo "Unknown simulator device type \"$SIM_NAME\"" >&2; exit 1; }
xcrun simctl create "$SIM_NAME" "$type" "$newest"
