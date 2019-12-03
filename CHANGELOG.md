## 3.4.3
### Modification of files
The referenced Docker images were changed.

### New services
We added the following new folders:
- core/nlp-deployments/ko
- core/nlp-deployments/ar
- core/deployments/service-nlp-ner

The ``service-nlp-ner`` is used for ``entity recognition`` and currently only important for our new languages ``Arabic`` and ``Korean``. There is no need for you to deploy this when you are not utilizing these two new languages! The service will be mandatory in the future, though.

### New limits
We have adjusted the limits for the ``service-export-import`` microservice:

Old values
- memory request: 360M
- memory limit: 450M
- cpu limit: 0.2

New values
- memory request: 680M
- memory limit: 850M
- cpu limit: 0.5

---

## 3.4.2
### Modification of files
The referenced Docker images were changed.

---

## 3.4.1
### Modification of files
The referenced Docker images were changed.

### New limits
We have adjusted the limits for the ``service-logs`` microservice:

Old values
- memory request: 60M
- memory limit: 75M

New values
- memory request: 100M
- memory limit: 120M

---

## 3.4.0
### Modification of files
Since we officially added Kubernetes support with our 3.4.0 release of COGNIGY.AI, we changed the structure of the repository a bit. We renamed several things:
- service-nlp-2.0.0-<language>.yaml was renamed to service-nlp-2-0-0-<language>.yaml
- The volume-claim "stateful-mongo-server.yaml" was renamed to "mongo-server.yaml"
- The volume "stateful-mongo-server.yaml" was renamed to "mongo-server.yaml"

In addition, the did the following things:
- We added a ``new secret`` to the deployment ``service-analytics-odata`` so that it can use the new conversations ODATA API.
- We added the environment variable ``NLP_REDIS_LOCK=false`` to all nlp deployments.
- We split the ``GE`` nlp deployment into several languages that now all reside in seperate folders witin the ``core/nlp-deployments`` folder.
- We also changed the config-map ``languages.yaml`` to add ``Portugese support`` and change some settings for ``Arabic``. You therefore need to re-apply this config-map.

### New limits
We also ``changed the limits of all of the deployments`` for our 3.4.0 release based on monitoring results, as well as changed the ``livenessProbe``. 

### Monitoring
We added ``cadvisor support`` for monitoring. To use this, you have to re-apply the config-map ``monitoring/config-maps/prometheus-config.yaml`` and deploy the daemonset ``monitoring/daemonsets/cadvisor.yaml``.

### Management UI
You also need to update the ```Management UI``` to be compatible with 3.4.0. To do this, re-apply the deployment ``management-ui/deployments/management-ui.yaml``