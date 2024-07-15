# Monitoring server installation 


## InfluxDB 

Official [guide](https://docs.influxdata.com/influxdb/v2/install)

Install:
```
wget -qO- https://repos.influxdata.com/influxdb.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/influxdb.gpg > /dev/null
export DISTRIB_ID=$(lsb_release -si); export DISTRIB_CODENAME=$(lsb_release -sc)
echo "deb [signed-by=/etc/apt/trusted.gpg.d/influxdb.gpg] https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list > /dev/null

sudo apt update && sudo apt install influxdb

sudo systemctl enable --now influxdb

sudo systemctl start influxdb

sudo systemctl status influxdb
```

Setup database (change the passwords given in the example on more secure ones):
```
influx
> create database umeemetricsdb
> create user metrics with password 'password'
> grant WRITE on umeemetricsdb to metrics
> create user grafana with password 'other_password'
> grant READ on umeemetricsdb to grafana
```

Keep database user and password in order to use it later for agent configuration. Write it. 

In the case of using standalone instance for monitoring staff,  you should know your node external ip address (you can know it by command ```curl ifconfig.me```).
In the case of installation on the same instance, just use **localhost** or **127.0.0.1**
