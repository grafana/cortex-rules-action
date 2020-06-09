#!/bin/sh
#
# Sync/Diff rules to a Cortex cluster using the cortex tool

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: " + "$@" >&2
}


if [ -z "${RULES_DIR}" ]; then
  RULES_DIR="./"
fi

if [ -z "${COMMIT_SHA}" ]; then
  err "COMMIT_SHA has not been set"
  exit 1
fi

if [ -z "${CORTEX_TENANT_ID}" ]; then
  err "CORTEX_TENANT_ID has not been set."
  exit 1
fi

if [ -z "${CORTEX_ADDRESS}" ]; then
  err "CORTEX_ADDRESS has not been set."
  exit 1
fi


# unclear if these two steps should fail the entire action run
OUTPUT=$(/usr/bin/cortextool rules prepare --rule-dirs="${RULES_DIR}")
STATUS=$?

OUTPUT=$(/usr/bin/cortextool rules lint --rule-dirs="${RULES_DIR}")
STATUS=$?

# diff should be last step before merging, dump the diff to a github comment, and 
# if we're okay/merge then we can sync on the next run of the action in master
OUTPUT=$(/usr/bin/cortextool rules diff --rule-dirs="${RULES_DIR}")
STATUS=$?

# rules check should fail the whole script run if it fails, and dump the output to a comment
OUTPUT=$(/usr/bin/cortextool rules check --rule-dirs="${RULES_DIR}")
STATUS=$?

# so we need to get the exit status of these commands, check that they produce error exit codes not 0s

echo "${OUTPUT}"
echo ::set-output name=detailed::"${OUTPUT}"
SUMMARY=$(echo "${OUTPUT}" | grep Summary)
echo ::set-output name=summary::"${SUMMARY}"

# if everythings gone well, and if we're on master branch, we should sync the rules to cortex
# OUTPUT=$(/usr/bin/cortextool rules sync --rule-dirs="${RULES_DIR}")
# STATUS=$?

exit $STATUS