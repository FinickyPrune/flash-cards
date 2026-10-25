#!/usr/bin/env bash
# Prints the UDID of the simulator to use for build/test/run.
# Picks SIM_NAME on the newest iOS runtime. The default is pinned so local runs and CI test on
# the same device (CI's first iPhone used to differ from the local one, #23).
set -euo pipefail

SIM_NAME="${SIM_NAME:-iPhone 18 Pro}"

xcrun simctl list devices available -j | jq -r --arg name "$SIM_NAME" '
  .devices
  | to_entries
  | map(select(.key | test("SimRuntime\\.iOS-[0-9]+(-[0-9]+)*$")))
  | sort_by(.key | capture("iOS-(?<v>[0-9]+(-[0-9]+)*)$").v | split("-") | map(tonumber))
  | reverse
  | map(.value[] | select(.name | startswith("iPhone")))
  | map(select($name == "" or .name == $name))
  | first
  | .udid // empty
' | grep . || { echo "No available iPhone simulator${SIM_NAME:+ named \"$SIM_NAME\"}" >&2; exit 1; }
