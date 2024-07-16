#!/bin/bash
pushd `dirname ${0}` >/dev/null || exit 1

# Get node variables
source ./vars.sh
# Get timestamp
now=$(date +%s%N)

# fill header
logentry="umee_balance"
if [ -n "${COS_VALOPER}" ]; then logentry=$logentry",valoper=${COS_VALOPER}"; fi

commission=$(${COS_BIN_NAME} query distribution commission ${COS_VALOPER} -o json --node "${NODE_RPC}"| jq -r ' .commission[]  | select(.denom=="'${COS_DENOM}'") | .amount | tonumber')
if [ -z "${commission}" ]; then commission=-1; fi
rewards=$(${COS_BIN_NAME} query distribution rewards ${COS_WALADDR} ${COS_VALOPER} --node "${NODE_RPC}" -o json | jq  '.rewards[] | select(.denom=="'${COS_DENOM}'") | .amount | tonumber')
if [ -z "${rewards}" ]; then rewards=-1; fi
balance=$(${COS_BIN_NAME} q bank balances ${COS_WALADDR} --node "${NODE_RPC}" -o json | jq  '.balances[] | select(.denom=="'${COS_DENOM}'") | .amount | tonumber')
if [ -z "${balance}" ]; then balance=-1; fi

echo $logentry" balance=${balance},commission=${commission},rewards=${rewards} $now"
popd > /dev/null || exit 1
