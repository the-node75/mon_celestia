# Monitoring server installation 


## InfluxDB 

Official [guide](https://docs.influxdata.com/influxdb/v2/install)

You can use any installation option, we will here consider running in docker.

Setup variables
```
ADMIN_USERNAME=admin
ADMIN_PASSWORD=<admin password>
ORG_NAME=<your organization name>
BUCKET_NAME=backet

INFLUX_DATA=/var/lib/influxdb2
INFLUX_CONF=/etc/influxdb2
```

Create docker network for connect to Grafana
```
docker network create monitoring
```

Init container:
```
docker run \
 --name influxdb2 \
 --publish 8086:8086 \
 --mount type=volume,source=influxdb2-data,target=${INFLUX_DATA} \
 --mount type=volume,source=influxdb2-config,target=${INFLUX_CONF} \
 --env DOCKER_INFLUXDB_INIT_MODE=setup \
 --env DOCKER_INFLUXDB_INIT_USERNAME=$ADMIN_USERNAME \
 --env DOCKER_INFLUXDB_INIT_PASSWORD=$ADMIN_PASSWORD \
 --env DOCKER_INFLUXDB_INIT_ORG=$ORG_NAME \
 --env DOCKER_INFLUXDB_INIT_BUCKET=$BUCKET_NAME \
 --network monitoring \
 influxdb:2
```

Remove container and rerun as daemon:
```
docker rm influxdb2

docker run -d \
 --name influxdb2 \
 --publish 8086:8086 \
 --mount type=volume,source=influxdb2-data,target=${INFLUX_DATA} \
 --mount type=volume,source=influxdb2-config,target=${INFLUX_CONF} \
 --network monitoring \
 influxdb:2
```

Check InfluxDB logs: 
```
docker logs influxdb2 -f
```

### Setup database

Create celestia bucket
```
docker exec influxdb2 \
influx bucket create \
  -n celestia -o $ORG_NAME
```

Expected output:
```
ID                      Name            Retention       Shard group duration    Organization ID         Schema Type
f9************1a        celestia        infinite        168h0m0s                a0************79        implicit
```

Set bucket id as bash variable (use your ID):
```
BUCKET_ID=f9************1a
```

Create token for nodes (write only)

```
docker exec influxdb2 \
influx auth create \
  --description "Node token" \
  --org $ORG_NAME \
  --write-bucket $BUCKET_ID   
```

Expected output:
```
ID                      Description     Token                                                                                    User Name        User ***
0d59e8d32df92000        Node token      1************************************************************************************Q== admin            0d59d***
```

> IMPORTANT! Save your token in safe place
> You'll need it when you set up Telegraf on nodes.

Create token for Grafana (read only)

```
# token for grafana
docker exec influxdb2 \
influx auth create \
  --description "grafana token" \
  --org $ORG_NAME \
  --read-bucket $BUCKET_ID \
  --read-dashboards \
  --read-tasks \
  --read-telegrafs
```

Expected output:
```
ID                      Description     Token                                                                                           User Name       User ID ***               Permissions
0d59e9b87ab92000        grafana token   1************************************************************************************Q==        admin           0d59d62c***
```
> IMPORTANT! Save your token in safe place.
> You'll need it when you set up Grafana.



## Grafana 

Setup variables and preparation
```
MYGF_HOME=/opt/grafana

sudo mkdir $MYGF_HOME
sudo mkdir $MYGF_HOME/data
sudo chown -R $(id -u):$(id -u) $MYGF_HOME
```

Start grafana daemon
```
docker run -d --name=grafana \
  --restart always \
	-p 3000:3000  \
	--network monitoring \
	--user "$(id -u)" \
	-v "$MYGF_HOME/data:/var/lib/grafana" \
	grafana/grafana-oss
```

Check grafana logs: 
```
docker logs grafana -f
```

Use a web browser to further customize the grafana in the GUI:

1. go to http://YOUR_SERVER_IP:3000.
2. log in to grafana with default username/password: *admin* / *admin*
3. setup new grafana password
4. 


