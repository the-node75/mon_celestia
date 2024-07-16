#!/bin/bash
pushd `dirname ${0}` >/dev/null || exit 1

# Get node variables
source ./vars.sh
# Set default curl timeout
TO=2

# Get timestamp
now=$(date +%s%N)

logentry="celestia_bridge"

#if [ -n "${COS_VALOPER}" ]; then logentry=$logentry",valoper=${COS_VALOPER}"; fi
ver_string=$(${BRIDGE_BINARY} version | grep "Semantic version")
IFS=' ' read -ra words <<< "$ver_string"
version="${words[-1]}"
if [ -z "${version}" ]; then version="unknown"; fi

logentry="$logentry version=\"$version\""	 

# health is great by default
health=0


if [ -z "$CELESTIA_NODE_AUTH_TOKEN" ];
then 
    echo "ERROR: can't find auth token">&2 ;
    health=1	
    echo "$logentry,health=$health $now"
else
	if [ -z "$BRIDGE_RPC" ];
	then 
		echo "ERROR: can't find BRIDGE_RPC value">&2 ;
		health=2
		echo "$logentry,health=$health $now"
	else
	
	# Get bridge height

	height=$(curl -X POST -s \
	  --connect-timeout ${TO} \
	  -H "Authorization: Bearer $CELESTIA_NODE_AUTH_TOKEN" \
	  -H 'Content-Type: application/json' \
	  -d '{"jsonrpc":"2.0","id":0,"method":"header.LocalHead","params":[]}' \
	  ${BRIDGE_RPC} | jq -r .result.header.height)
	  
	if [ -z "${height}" ]
	then	    
		echo "ERROR: bridge height return empty string">&2 ;
		health=3 
		bridge_height=-1
	fi
	
	logentry="$logentry,bridge_height=$height"	 
	
	status=$(curl --connect-timeout ${TO} -s ${BRIDGE_REF_RPC_NODE}/status)
    if [ -z "$status" ];
    then
        echo "ERROR: can't connect to reference RPC">&2 ;
        health=4        
    else
        # Get block height
        ref_height=$(jq -r '.result.sync_info.latest_block_height' <<<$status)
		let "bridge_lag = $height - $ref_height"
		logentry="$logentry,bridge_lag=$bridge_lag"
	fi
	 
	echo "$logentry,health=$health $now"
	fi # rpc var check
fi # token check

popd > /dev/null || exit 1