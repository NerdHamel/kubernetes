# Prometheus setting up guide

To monitor COGNIGY installation on kubernetes we use prometheus. [Prometheus](https://prometheus.io/docs/introduction/overview/) is an open-source systems monitoring and alerting toolkit originally built at SoundCloud. Prometheus can scrape metrics and build a data model with time series data identified by metrics name and key/value pair. 

Here to all the necessary files to install prometheus are kept in under `monitoring_new` folder. The folder structure looks like below 

```
├── architechture.jpeg
├── grafana
│   ├── configmaps
│   │   ├── dashboard-provider.yaml
│   │   ├── dashboard.yaml
│   │   ├── datasource.yaml
│   │   └── grafana-config.yaml
│   ├── deployment.yaml
│   ├── secrets
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
│   ├── config-map.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── README.md
└── service-monitoring
    ├── deployment.yaml
    ├── secrets
    │   └── prometheus-password.yaml
    └── service.yaml
```
At first here we will discuss about `kube-state-metrics`. Later we will discuss about deploying the `service-monitoring` and `node-exporter` metrics. Later we will discuss about deploying `prometheus` and `grafana`.

But before all of that lets talk about the architechture first. 


## Architechture 

An ideal kubernetes based microservice architechture looks like below 

![](architechture.jpeg)

Where prometheus can talk with every kubernetes node and pull the necessary metrics from there. All the other external component can use those metrics by taking from prometheus. Such as alertmanager, grafana etc. Also some external persistent storage can use to store the metrics for longer period. 

> Please note, at the beginneing we will use the TSDB available with prometheus. 

We are aiming to use `kube-state-metrics` to monitor pods, services and deployment and `Node-exporter` to monitor nodes system metrics. Though `Kube-state-metrics` can provide some metrics about kubernetes node too, but its better to use `node-exporter` for more information. 

## Kube-state-metrics

kube-state-metrics is a simple service that listens to the Kubernetes API server and generates metrics about the state of the objects. kube-state-metrics is about generating metrics from Kubernetes API objects without modification. This ensures that features provided by kube-state-metrics have the same grade of stability as the Kubernetes API objects themselves. To get more information about kube-state-metrics please check [here](https://github.com/kubernetes/kube-state-metrics). 

Setting up kube-state-metrics is fairly simple. Please run the following command to setup 

```
kubectl apply -f kube-state-metrics-configs
```
It will create the deployment under `kube-system` namespace. Check the deployment by running following command

```
kubectl get deployments -n kube-system
```
## Node-exporter

Prometheus can export hardware and os metrics using node exporter. Node exporter is very popular to monitor linux system metrics.

To setup node-exporter first we need to create a namespace. It is not mandatory, but this helps to keep the monitoring resources more organized. 

```
kubectl create namespace monitoring
```

As we want to monitor all the kubernetes nodes so we need to install node exporter in every nodes. For that we can use the technique called [daemonset](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). This is a smooth way to install node exporter as kubernetes service which will run on every node. 

To deploy node exporter as a daemonset 

```
kubectl apply -f node-exporter/node-exporter.yaml -n monitoring
```
## Service-monitoring

Service monitoring is the core monitoring service which is integrated in Cognigy AI product. Before deploying the service monitoring we required to create a secret for the basic auth between service-monitoring and prometheus. To create the secret 

```
kubectl apply -f service-monitoring/secrets
```
Aftar that we can simply deploy the application 

```
kubectl apply -f service-monitoring/deployment.yaml
```
To expose the application as a service 

```
kubectl apply -f service-monitoring/service.yaml
```
## Generate Alertrule and Alertmanager configmap

In this setup we are using two configmaps which will be different for each environement. One is `configmap.yaml` for alert manager and the other one is  `alertrule.yaml`. We are using a bash script to generate these files. To do so 

```
bash alertrulegenerator.sh
```
This script will ask the **HOST** which will be equal to your environement name(i.e localhost or dev.cognigy.ai) and the **pager duty integration api key** which will be the api key to integrate alert manager with pager duty. You also need to enter all the node IPs along with node-exporter port where node-exporter is running.

## Prometheus 

At beginneing of prometheus setup `clusterRole` need to be create 

```
kubectl apply -f prometheus/clusterRole.yaml
```
We need to create the basic auth secret for prometheus as well to allow prometheus to communicate with `service monitoring`. As prometheus will run under monitoring namespace so we can not simply use the same secret which we have created for service-monitoring. We need to create the same secret under `monitoring` namespace. To do that we can simply run the following command
```
kubectl apply -f service-monitoring/secrets -n monitoring  
```
After that we create a `configmaps` which contains the configuration of prometheus and the alert rules. 

```
kubectl apply -f prometheus/configmaps
```
At this point we have everything which are necessary to run prometheus deployment. To run the prometheus deployment 

```
kubectl apply -f prometheus/deployment.yaml
```
To access the prometheus dashboard over a IP we deployed it as a service. 

```
kubectl apply -f prometheus/service.yaml
```
Once created, we can access the prometheus dashboard over `kubernetes-IP` and port `30000`. 

## Grafana

To deploy grafana we need to create few config maps which will be used to autoprovison datasource and dashboard. To create the configmaps
```
kubectl apply -f grafana/configmaps
```
We also need to create a secret to initialize the password for grafana admin user. 
```
kubectl apply -f grafana/secrets/grafana-pass.yaml
```
Now we can deploy grafana application 
```
kubectl apply -f grafana/deployment.yaml
```
To expose grafana on port `32767` we need to create the service
```
kubectl apply -f grafana/service.yaml
```
> please note Grafana credential is different per environement. In that case proper secret creation is important. For example if you want to deploy grafana on beta cluster you need to apply the `grafana-pass-betav4` as secret. 

## Alert Manager 

To deploy the alert manager 

```
kubectl apply -f alert-manager/configmap.yaml
kubectl apply -f alert-manager/deployment.yaml
kubectl apply -f alert-manager/service.yaml
```
It will expose the alert-manager service on port `32100`
