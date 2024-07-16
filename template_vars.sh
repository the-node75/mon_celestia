# monitoring variables template

#MON_MODE=rpc   # use for RPC/sentry nodes
MON_MODE=val   # use for Validator nodes


COS_BINARY=           # insert path to celestia consensus node binary, example: /root/go/bin/celestia-appd or /home/user/go/bin/celestia-appd
COS_CHAIN_ID=celestia # chain id "celestia" for mainnet, "mocha-4" for testnet
COS_DENOM=utia        # denominator. don't change
COS_PORT_RPC=26657    # insert node RPC port here if it's not default (26657)
COS_PORT_API=1317     # insert node API port here if it's not default (1317)
COS_VALOPER=          # validator address, example: celestiavaloper1234545636767376535673
COS_WALADDR=          # validator wallet address, example: celestia123454563676***376535673


BRIDGE_BINARY=        # insert path to celestia bridge node binary, example: /root/go/bin/celestia
BRIDGE_STORE_PATH=    # insert paht to bridge storadge, example: /root/.celestia
BRIDGE_RPC_PORT=      # insert port of celestia bridge node rpc


# generated variables, do not change
NODE_RPC="http://localhost:${COS_PORT_RPC}"
NODE_API="http://localhost:${COS_PORT_API}"
BRIDGE_RPC="http://localhost:${BRIDGE_RPC_PORT}"
CELESTIA_NODE_AUTH_TOKEN=$(${BRIDGE_BINARY} bridge auth admin --p2p.network ${COS_CHAIN_ID} --node.store ${BRIDGE_STORE_PATH})