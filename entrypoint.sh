#!/bin/sh
#
# Interact with the Cortex Ruler API using the cortextool

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: " + "$@" >&2
}

# For commands that interact with the server, we need to verify that the
# CORTEX_TENANT_ID and CORTEX_ADDRESS are set.
verifyTenantAndAddress() {
  if [ -z "${CORTEX_TENANT_ID}" ]; then
    err "CORTEX_TENANT_ID has not been set."
    exit 1
  fi

  if [ -z "${CORTEX_ADDRESS}" ]; then
    err "CORTEX_ADDRESS has not been set."
    exit 1
  fi
}

LINT_CMD=lint
CHECK_CMD=check
PREPARE_CMD=prepare
SYNC_CMD=sync
DIFF_CMD=diff
PRINT_CMD=print

if [ -z "${COMPONENT}" ]; then
  echo "COMPONENT not set, select either RULER or ALERTMANAGER"
  exit 1
fi

if [ -z "${RULES_DIR}" ]; then
  echo "RULES_DIR not set, using './' as a default."
  RULES_DIR="./"
fi

if [ ${COMPONENT} == "ALERTMANAGER" ] && [ -z "${ALERTMANAGER_CONFIG_PATH}" ]; then
  echo "No ALERTMANAGER_CONFIG_PATH variable set. Defaulting to ./alertManager.yml"
  ALERTMANAGER_CONFIG_PATH=./alertManager.yml
fi

if [ -z "${ACTION}" ]; then
  err "ACTION has not been set."
  exit 1
fi

if [ "${COMPONENT}" == "RULER" ]; then
  case "${ACTION}" in
    $SYNC_CMD)
      verifyTenantAndAddress
      OUTPUT=$(/usr/bin/cortextool rules sync --rule-dirs="${RULES_DIR}" "$@")
      STATUS=$?
      ;;
    $DIFF_CMD)
      verifyTenantAndAddress
      OUTPUT=$(/usr/bin/cortextool rules diff --rule-dirs="${RULES_DIR}" "$@")
      STATUS=$?
      ;;
    $LINT_CMD)
      OUTPUT=$(/usr/bin/cortextool rules lint --rule-dirs="${RULES_DIR}" "$@")
      STATUS=$?
      ;;
    $PREPARE_CMD)
      OUTPUT=$(/usr/bin/cortextool rules prepare -i --rule-dirs="${RULES_DIR}" "$@")
      STATUS=$?
      ;;
    $CHECK_CMD)
      OUTPUT=$(/usr/bin/cortextool rules check --rule-dirs="${RULES_DIR}" "$@")
      STATUS=$?
      ;;
    $PRINT_CMD)
        OUTPUT=$(/usr/bin/cortextool rules print "$@")
        STATUS=$?
        ;;
    *)
      err "Unexpected action '${ACTION}'"
      exit 1
      ;;
  esac
elif [ "${COMPONENT}" == "ALERTMANAGER" ]; then
  OUTPUT=$(/usr/bin/cortextool alertmanager load ${ALERTMANAGER_CONFIG_PATH})
  STATUS=$?
else
  echo "Invalid component selected, use RULER or ALERTMANAGER"
  exit 1
fi

echo "${OUTPUT}"
echo ::set-output name=detailed::"${OUTPUT}"
SUMMARY=$(echo "${OUTPUT}" | grep Summary)
echo ::set-output name=summary::"${SUMMARY}"

exit $STATUS
