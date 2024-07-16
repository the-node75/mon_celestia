# Installation monitoring tools on nodes

## Install Telegraf

```
wget -q https://repos.influxdata.com/influxdata-archive_compat.key
echo '393e8779c89ac8d958f81f942f9ad7fb82a25e133faddaf92e15b16e6ac9ce4c influxdata-archive_compat.key' | sha256sum -c && cat influxdata-archive_compat.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg > /dev/null
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' | sudo tee /etc/apt/sources.list.d/influxdata.list

sudo apt update && sudo apt install telegraf

sudo systemctl enable --now telegraf
sudo systemctl is-enabled telegraf

# make the telegraf user sudo and adm to be able to execute scripts as umee user
sudo adduser telegraf sudo
sudo adduser telegraf adm
sudo -- bash -c 'echo "telegraf ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'

# Backup configuration
sudo mv /etc/telegraf/telegraf.conf /etc/telegraf/telegraf.conf.orig
```

### Create new configuration for Telegraf

#### Basic configuration (for all type of nodes)

Setup variables
```
MON_SERVER_URL="http://YOUR_MONITORING_SERVER_IP:8086"
ORG_NAME=<your organization name>
BUCKET_NAME=celestia
INFLUXDB_NODE_TOKEN=<your node token for InfluxDB>
```


```
tee $HOME/telegraf.conf > /dev/null <<EOF
# Global Agent Configuration
[agent]
  hostname = "$(hostname -s)"
  flush_interval = "15s"
  interval = "15s"
# Input Plugins
[[inputs.cpu]]
  percpu = true
  totalcpu = true
  collect_cpu_time = false
  report_active = false
[[inputs.disk]]
  ignore_fs = ["devtmpfs", "devfs"]
[[inputs.diskio]]
[[inputs.mem]]
[[inputs.net]]
[[inputs.nstat]]
[[inputs.netstat]]
[[inputs.linux_sysctl_fs]]
[[inputs.system]]
[[inputs.swap]]
[[inputs.processes]]
[[inputs.interrupts]]
[[inputs.kernel]]

[[outputs.influxdb_v2]]
  ## The URLs of the InfluxDB cluster nodes.
  ##
  ## Multiple URLs can be specified for a single cluster, only ONE of the
  ## urls will be written to each interval.
  ##   ex: urls = ["https://us-west-2-1.aws.cloud2.influxdata.com"]
  urls = ["$MON_SERVER_URL"]
  
  ## Local address to bind when connecting to the server
  ## If empty or not set, the local address is automatically chosen.
  # local_address = ""

  ## Token for authentication.
  token = "${INFLUXDB_NODE_TOKEN}"
  
  ## Organization is the name of the organization you wish to write to.
  organization = "${ORG_NAME}"

  ## Destination bucket to write into.
  bucket = "${BUCKET_NAME}"
  
  
EOF
```

Setup config

```
sudo cp telegraf.conf /etc/telegraf/telegraf.conf
sudo systemctl restart telegraf
```

After that, your instance should start transmitting general information about the system (CPU,RAM,Drives,Network metrics)

#### Validator node setup 

Additional actions are required to tx validator metrics

```
cd $HOME
git clone https://github.com/the-node75/mon_celestia.git
cd $HOME/mon_celestia
cp template_vars.sh vars.sh
```

Edit variables file
```
nano vars.sh
```

Set `MON_MODE` to `val` for validator node, to `rpc`  for rpc, sentry and other not-validator nodes

Set path to celestia app binary to `COS_BINARY`, use `which celestia-appd` for resolving 

Set `COS_CHAIN_ID` variable 

Edit `COS_PORT_RPC` if you use custom consensus node rpc port 

Edit `COS_PORT_API` if you use custom consensus node api port 

Set your validator valoper to `COS_VALOPER` variable

Set your validator wallet address to `COS_WALADDR`

For Bridge nodes:

Set path to celestia binary to `BRIDGE_BINARY`

Set `BRIDGE_STORE_PATH` 

Set bridge node rpc port to `BRIDGE_RPC_PORT`

Edit `BRIDGE_REF_RPC_NODE` if you want to use a different reference consensus rpc endpoint 


