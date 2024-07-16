#!/bin/bash
pushd `dirname ${0}` >/dev/null || exit 1

# Get node variables
source ./vars.sh
# Set default curl timeout
TO=2

# Get timestamp
now=$(date +%s%N)

# Get umeed version
version=$(${COS_BINARY} version 2>&1)

# fill header
logentry="cos"
if [ -n "${COS_VALOPER}" ]; then logentry=$logentry",valoper=${COS_VALOPER}"; fi

# health is great by default
health=0

if [ -z "$version" ];
then 
    echo "ERROR: can't find binary">&2 ;
    health=1
    echo $logentry" health=$health $now"
else
    # Get node status
    status=$(curl --connect-timeout ${TO} -s ${NODE_RPC}/status)
    if [ -z "$status" ];
    then
        echo "ERROR: can't connect to RPC">&2 ;
        health=2
        echo $logentry" health=$health $now"
    else
        # Get block height
        block_height=$(jq -r '.result.sync_info.latest_block_height' <<<$status)
        # Get block time
        latest_block_time=$(jq -r '.result.sync_info.latest_block_time' <<<$status)
        let "time_since_block = $(date +"%s") - $(date -d "$latest_block_time" +"%s")"
        latest_block_time=$(date -d "$latest_block_time" +"%s")
        # check time
        if [ $time_since_block -gt 30 ]; then health=4; fi

        # Get catchup status
        catching_up=$(jq -r '.result.sync_info.catching_up' <<<$status)
        # Get Tendermint voting power
        voting_power=$(jq -r '.result.validator_info.voting_power' <<<$status)
        # Peers count
        peers_num=$(curl --connect-timeout ${TO} -s ${NODE_RPC}/net_info | jq -r '.result.n_peers')
        # Prepare metiric to out
        logentry=$logentry" ver=\"$version\",block_height=$block_height,catching_up=$catching_up,time_since_block=$time_since_block,latest_block_time=$latest_block_time,peers_num=$peers_num,voting_power=$voting_power"
        # Common validator statistic
        # Numbers of active validators
        list_limit=3000
        val_active_numb=$(${COS_BINARY} q staking validators -o json --limit=${list_limit} --node "${NODE_RPC}" |\
        jq '.validators[] | select(.status=="BOND_STATUS_BONDED")' | jq -r ' .description.moniker' | wc -l)
        logentry="$logentry,val_active_numb=$val_active_numb"

        if [ $MON_MODE == "rpc" ]
        then
            health=100 # Health RPC mode code
        else
            
            #
            # Get our validator metrics
            #
            if [ -n "${COS_VALOPER}" ]
            then
                val_status=$(${COS_BINARY} query staking validator ${COS_VALOPER} --output json --node "${NODE_RPC}")
            fi
            # Parse validator status
            if [ -n "$val_status" ]
            then
                jailed=$(jq -r '.jailed' <<<$val_status)
                # Get all delegated to node tokens num
                delegated=$(jq -r '.tokens' <<<$val_status)
                # Get bond status
                bond=3
                if [ $(jq -r '.status' <<<$val_status) == "BOND_STATUS_UNBONDED" ]; then bond=2; fi
                if [ $(jq -r '.status' <<<$val_status) == "BOND_STATUS_UNBONDING" ]; then bond=1; fi
                if [ $(jq -r '.status' <<<$val_status) == "BOND_STATUS_BONDED" ]; then bond=0; fi
                # Missing blocks number in window
                #bl_missed=$(jq -r '.missed_blocks_counter' <<<$($COS_BINARY q slashing signing-info $($COS_BINARY tendermint show-validator) -o json --node "${NODE_RPC}"))
				bl_missed=$(${COS_BINARY} query slashing signing-info "{\"@type\":\"/cosmos.crypto.ed25519.PubKey\",\"key\":\"$(${COS_BINARY} query staking validator ${COS_VALOPER} -oj --node "${NODE_RPC}" | jq -r .consensus_pubkey.key)\"}" --output json | jq -r '.missed_blocks_counter | tonumber');
				
                if [ -z "${bl_missed}" ]; then bl_missed=-1; fi
                # Our validator stake value rank (if not in list assign -1 value)
                val_rank=$(${COS_BINARY} q staking validators -o json --limit=${list_limit} --node "${NODE_RPC}" | \
                jq '.validators[] | select(.status=="BOND_STATUS_BONDED")' | jq -r '.tokens + " - " + .operator_address'  | sort -gr | nl |\
                grep  "${COS_VALOPER}" | awk '{print $1}')
                if [ -z "$val_rank" ]; then val_rank=-1; fi
                logentry="$logentry,jailed=$jailed,delegated=$delegated,bond=$bond,bl_missed=$bl_missed,val_rank=$val_rank"
            else 
                health=3 # validator status problem
            fi
        fi # MON_MODE
        echo "$logentry,health=$health $now"
    fi # rpc check
fi # binary check

popd > /dev/null || exit 1
