# COGNIGY.AI in k8s
This is the official Kubernetes (``k8s``) manifest repository for COGNIGY.AI. You will need these files in order to deploy Cognigy.AI on top of Kubernetes. For dedicated instructions on how you can use this repository, please have a look at our [production documentation](https://docs.cognigy.com/docs/installation-and-dev-ops-guide).

# CHANGELOG
This changelog contains changes to the structure of this repository. You can find the changelog for COGNIGY.AI [here](https://docs.cognigy.com/docs/release-notes) 

## 3.4.1
### Modification of files
Nothing major changes except referenced Docker images.

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
