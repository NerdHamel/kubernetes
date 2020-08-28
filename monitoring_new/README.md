# Prometheus setting up guide

To monitor COGNIGY installation on kubernetes we use prometheus. [Prometheus](https://prometheus.io/docs/introduction/overview/) is an open-source systems monitoring and alerting toolkit originally built at SoundCloud. Prometheus can scrape metrics and build a data model with time series data identified by metrics name and key/value pair. 

Here to all the necessary files to install prometheus are kept in under `monitoring_new` folder. The folder structure looks like below 

```
.
├── alert-manager
│   ├── configmap.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── alertrulegenerator.sh
├── architechture.jpeg
├── grafana
│   ├── configmaps
│   │   ├── dashboard-provider.yaml
│   │   ├── dashboard.yaml
│   │   ├── datasource.yaml
│   │   └── grafana-config.yaml
│   ├── deployment.yaml
│   ├── secrets.dist
│   │   └── grafana-pass.yaml
│   └── service.yaml
├── kube-state-metrics-configs
│   ├── cluster-role-binding.yaml
│   ├── cluster-role.yaml
│   ├── deployment.yaml
│   ├── service-account.yaml
│   └── service.yaml
├── node-exporter
│   ├── deployment.yaml
│   └── service.yaml
├── prometheus
│   ├── clusterRole.yaml
│   ├── configmaps
│   │   ├── alertrule.yaml
│   │   └── config-map.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── README.md
└── service-monitoring
    ├── deployment.yaml
    ├── secrets.dist
    │   └── prometheus-password.yaml
    └── service.yaml

```
We will discuss the installation procedure for monitoring, but before all of that lets talk about the architechture first. 

## Architechture 

An ideal kubernetes based microservice architechture looks like below 

![](architechture.jpeg)

Where prometheus can talk with every kubernetes node and pull the necessary metrics from there. All the other external component can use those metrics by taking from prometheus. Such as alertmanager, grafana etc. Also some external persistent storage can use to store the metrics for longer period. 

> Please note, at the beginneing we will use the TSDB available with prometheus. 

We are aiming to use `kube-state-metrics` to monitor pods, services and deployment and `Node-exporter` to monitor nodes system metrics. Though `Kube-state-metrics` can provide some metrics about kubernetes node too, but its better to use `node-exporter` for more information.

To monitor some core metrics we use a service called `service-monitoring`. This will give you more clear overview about the product performance. 

## Prerequisites

Before installing core monitoring infrastructure we need to make sure that all the metrics are up properly. For that we need to setup the following components

1. Kube-state-metrics
2. Node-exporter
3. Service-monitoring

Beside Service-monitoring we will setup all other monitoring components under `monitoring` namespace. To create that 
```
kubectl create namespace monitoring
```
### Kube-state-metrics

kube-state-metrics is a simple service that listens to the Kubernetes API server and generates metrics about the state of the objects. kube-state-metrics is about generating metrics from Kubernetes API objects without modification. This ensures that features provided by kube-state-metrics have the same grade of stability as the Kubernetes API objects themselves. To get more information about kube-state-metrics please check [here](https://github.com/kubernetes/kube-state-metrics). 

Setting up kube-state-metrics is fairly simple. Please run the following command to setup 

```
kubectl apply -f kube-state-metrics-configs
```
It will create the deployment under `kube-system` namespace. Check the deployment by running following command

```
kubectl get deployments -n kube-system
```
### Node-exporter

Prometheus can export hardware and os metrics using node exporter. Node exporter is very popular to monitor linux system metrics.

As we want to monitor all the kubernetes nodes so we need to install node exporter in every nodes. For that we can use the technique called [daemonset](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). This is a smooth way to install node exporter as kubernetes service which will run on every node. 

To deploy node exporter as a daemonset 

```
kubectl apply -f node-exporter/
```
### Service-monitoring

Service monitoring is the core monitoring service which is integrated in Cognigy AI product. Before deploying the service monitoring we required to create a secret for the basic auth between service-monitoring and prometheus. To create the secret first rename `secrets.dist` to `secrets`. After that enter your desired password in `secrets/prometheus-password.yaml` file. 

```
data:
  # your prometheus password, hex
  password: <your desired password>
```
> Please note, the password has to be base64 decoded 

After that to create the secret
```
kubectl apply -f service-monitoring/secrets
```
Aftar that we can simply deploy the application 

```
kubectl apply -f service-monitoring/deployment.yaml
kubectl apply -f service-monitoring/service.yaml
```
## Setting up core monitoring services

When all the metrics are up we can go forward to setting up the core monitoring services which includes 
- Prometheus
- Grafana
- Alert manager 

### Generate necessary templates 

In this setup we are using four configmaps which will be different for each environement. One is `configmap.yaml` for alert manager and the other two is  `alertrule.yaml` and `config-map.yaml` for prometheus. The last one is `dashboard.yaml` configmap for grafana. Also We are using a bash script to generate these files. To do so 

```
bash alertrulegenerator.sh
```
This script will ask the the follwing variables
1. **Enter HOST** : This will be equal to your environement name(example: localhost or dev.cognigy.ai) 
2. **Enter pager duty integration api key** :  This will be the api key to integrate alert manager with pager duty. 
3. **Enter all the IP which you want to use as Node-exporter target. The input format will be like 'IP-1:31000', 'IP-2:31000',..,'IP-n:31000'** : These will be node-exporter target servers IPs. 
4. **Enter the endpoint url** : This will be the cognigy endpoint url for that particular environment(example: endpoint-app.cognigy.ai)
5. **Enter the api url** : This will be the cognigy api url for that particular environment(example: api-app.cognigy.ai)

### Prometheus 

We need to create the basic auth secret for prometheus as well to allow prometheus to communicate with `service monitoring`. As prometheus will run under monitoring namespace so we can not simply use the same secret which we have created for service-monitoring. We need to create the same secret under `monitoring` namespace. To do that 

```
kubectl apply -f service-monitoring/secrets -n monitoring  
```
To deploy the prometheus 

```
kubectl apply -f prometheus/clusterRole.yaml
kubectl apply -f prometheus/configmaps
kubectl apply -f prometheus/deployment.yaml
kubectl apply -f prometheus/service.yaml
```
Once created, we can access the prometheus dashboard over `kubernetes-IP` and port `30000`. 

## Grafana

To deploy grafana we need to create few config maps which will be used to autoprovison datasource and dashboard. To create the configmaps
```
kubectl apply -f grafana/configmaps
```
We also need to create a secret to initialize the password for grafana admin user. To do that rename `secrets.dist` folder to `secrets` and enter the admin user and password in base64 decoded format in `grafana-pass.yaml` file. 

After that to create the grafana 
```
kubectl apply -f grafana/secrets/
kubectl apply -f grafana/configmaps/
kubectl apply -f grafana/deployment.yaml
kubectl apply -f grafana/service.yaml
```
To access the grafana you need to use `<kubernetes-node-IP>:32767` 

## Alert Manager 

To deploy the alert manager 

```
kubectl apply -f alert-manager/configmap.yaml
kubectl apply -f alert-manager/deployment.yaml
kubectl apply -f alert-manager/service.yaml
```
It will expose the alert-manager service on port `32100` and also integrate with Pagerduty. 
