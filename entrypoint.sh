#!/bin/sh
#
# Sync/Diff rules to a Cortex cluster using the cortex tool

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: " + "$@" >&2
}


if [ -z "${RULES_DIR}" ]; then
  RULES_DIR="./"
fi

if [ -z "${ACTION}" ]; then
  ACTION="diff"
fi

if [ -z "${CORTEX_TENANT_ID}" ]; then
  err "CORTEX_TENANT_ID has not been set."
  exit 1
fi

if [ -z "${CORTEX_ADDRESS}" ]; then
  err "CORTEX_ADDRESS has not been set."
  exit 1
fi


case "${ACTION}" in
  sync)
    OUTPUT=$(/usr/bin/cortextool rules sync --rule-dirs="${RULES_DIR}")
    STATUS=$?
    ;;
  diff)
    OUTPUT=$(/usr/bin/cortextool rules diff --rule-dirs="${RULES_DIR}")
    STATUS=$?
    ;;
  *)
    err "Unexpected action '${ACTION}'"
    exit 1
    ;;
esac

echo ::set-output name=detailed::"${OUTPUT}"
SUMMARY=$(echo "${OUTPUT}" | grep Summary)
echo ::set-output name=summary::"${SUMMARY}"

exit $STATUS
