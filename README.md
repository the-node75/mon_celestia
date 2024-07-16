# Celestia node monitoring tool
Monitoring tool for Celestia node based on Telegraf/InfluxDB/Grafana, based on https://github.com/shurinov/mon_umee

To monitor you node your should have installed and configured:
On node server:
* [Celestia consensus + DA nodes](https://docs.celestia.org/) which should be configured (correct moniker, validator key, network ports setup)
* [Telegraf agent](https://www.influxdata.com/time-series-platform/telegraf/)
* [mon_celestia](https://github.com/the-node75/mon_celestia) scripts set

On monitoring server:
* [InfluxDB](https://www.influxdata.com/products/influxdb/)
* [Grafana](https://grafana.com/)

It is possible to install the software on the node server instance. Hovewer, it is better to move it to standalone instance with opened web access to watch it from browser at any location.

## Features 

* General server's metrics (CPU load, RAM/Swap usage, Storage, Network statistic)
* Validator monitoring (binary version, sync state, block height, peers cnt, VP, missed blocks, etc)
* Bridge node monitoring (binary version, bridge height, bridge height lag)
* RPC/Sentry nodes monitoring

## The following steps will guide you through the setup process:

* [Setup monitoring server ](./doc/setup_monitoring_server.md)
* [Setup monitoring on node](./doc/setup_node_monitoring.md)


