#!/bin/bash
#
# Sync/Diff rules to a Cortex cluster using the cortex tool

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: " + "$@" >&2
}

readonly ACTION=$1
readonly RULES_DIR=$2

case "${ACTION}" in
  sync)
    /usr/bin/cortextool diff --rule-dirs="${RULES_DIR}"
    ;;
  diff)
    /usr/bin/cortextool diff --rule-dirs="${RULES_DIR}"
    ;;
  *)
    err "Unexpected action '${ACTION}'"
    exit 1
    ;;
esac