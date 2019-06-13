# Monitoring your COGNIGY.AI installation
In order to understand whether your COGNIGY.AI installation is working properly and performant, we added full support for Prometheus, a monitoring solution for containerized software products.

## Introduction
### Overview
COGNIGY.AI is a de-centralized and fully containerized software product. The whole software consists of multiple so-called services that work together and are loosely coupled over the network. A central message broker - we are using **RabbitMQ** - connects all services together and allows individual services to communicate with each other.

Individual service specialize in certain functionality and fullfil simple tasks, e.g. modifying state within a database. Most of our services produce metrics which can be used for further analysis and a detailed understanding of how the whole platform works. These metrics are collected by an additional service called:
**service-monitoring**

Metrics collected by our monitoring service can be retrieved from a running Prometheus installation. Prometheus scrapes (polling) the metrics on a regular basis and stores them within a highly performant time-series data-stream. It can also run queries against the stored metrics and e.g. extract meaningful meta-data.

Grafana, an additional product, can then be used to execute those queries against Prometheus, retrieve the metrics and render them on easy to understand dashboards.

The following schematics shows the data-flow between services:

![](monitoring.png)

Alertmanager can then also run queries against Prometheus and send alerts if certain conditions evaluate.

### Directory structure
This directory has the following folder-structure:
```
| - config-maps
| - deployments
| - secrets.dist
```

## Setup
This section will guide you through the process of setting up your monitoring stack for an existing COGNIGY.AI installation.

### Config map
---
In order to configure your monitoring pipeline, so-called config-maps are used. These store configuration data for individual software products like Prometheus, Alertmanager and Grafana.

Adjust the files within the ``config-maps`` directory so they work for your use-case.

After you are done with your modifications, deploy those within your K8s cluster:
```
kubectl apply -f monitoring/config-maps
```

Image Pull Secret
---
In order to pull ``docker images`` from our production registry, you need to define a so-called ``image pull secret``. Kubernetes will use it to authenticate against Cognigy's production registry.

Please have a look at our README file within the root of this repository for further details.

Secrets
---
We are using secrets for our monitoring stack as well. Secrets are a secure way to make sensitive data available for a running container.

The ``monitoring/secrets.dist`` folder contains empty API objects for K8s secrets. Create a copy of this folder and name it ``secrets``.

We have to define secrets for:
- grafana
- prometheus

Modify both files within ``monitoring/secrets``. For more information, have a look at the README file within the root of this repository.

After you did all modifications, apply the secrets to your cluster:
```
kubectl apply -f monitoring/secrets
```