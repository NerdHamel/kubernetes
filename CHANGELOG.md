# 3.6.7
## Modification of files
The referenced Docker images were changed.

## Change MongoDB and Redis-Persistent reclaim policy
The MongoDB and Redis-Persistent reclaim policy have been changed from `Delete` to `Retain`. Using `Retain` is safer especially in cloud environments as deleting PVs by accident will not de-privision and delete the data that resides within those.

---
# 3.6.6
## Modification of files
The referenced Docker images were changed.

## Traefik
We added http -> https redirect to the Traefik deployment, as well as the minimum supported TLS version

---
# 3.6.5
## Modification of files
The referenced Docker images were changed.

### stateful services
Cognigy.AI uses several other software products as dependencies. These are:
- MongoDB: The main database in which all of the data is being stored
- RabbitMQ: A powerful message broker we are using to inter-connect our microservices
- Redis: Used as a fast in-memory cache (redis.yaml) and as a fast key-value persistent database (redis-persistent.yaml)

We have updated MongoDB and Redis so they contain the latest patches (patches for the minor release we are using):
- Updated MongoDB from version 3.4.3 to 3.4.10
- Updated Redis (redis.yaml and redis-persistent.yaml) from version 4.0.2 to 4.0.10

The RabbitMQ version did not change.

In order to receive the new versions you have to completely stop your installation including the following deployments:
- core/stateful-deployments/mongo-server.yaml
- core/stateful-deployments/redis.yaml
- core/stateful-deployments/redis-persistent.yaml

There is no need to stop rabbitmq as it did not change!

Once everything stopped, you can apply the new files (mongo-server, redis, redis-persistent) from this repository in order to update to the patched versions.

### Updated authentication for Redis
We have also implemented changes regarding authentication for the ``redis.yaml`` - these changes do not apply to the ``redis-persistent.yaml`` deployment. Please get in touch with ``support@cognigy.com`` to get all details on how you can change your installation in order to adopt to these changes. We will provide more information and documentation.

If you are sure that your setup is properly secured and not accessible from outside, you may also omit this step.

---

# 3.6.4
## Modification of files
The referenced Docker images were changed.

---

# 3.6.3
## Modification of files
The referenced Docker images were changed.

---

# 3.6.2
## Modification of files
The referenced Docker images were changed.

---

# 3.6.1
## Modification of files
The referenced Docker images were changed.

### Traefik
If you are using Traefik as your ingress controller within your Kubernetes cluster, be sure to update it as we have updated it to v1.7.24 in order to fix a cookie-related issue.

### Services
Please be sure to re-apply your services in the ``core/services`` folder as we have added additional annotations to the kubernetes services for ``api`` and ``endpoint``. You can skip this step if you are not using Traefik as your ingress controller.

---

# 3.6.0
## Modification of files
The referenced Docker images were changed.

## New limits
We have adjusted the limits for the ``service-agent-ui`` microservice:

Old values
- memory request: 100M
- memory limit: 200M
- cpu request: 0.02
- cpu limit: 0.05

New values
- memory request: 60M
- memory limit: 75M
- cpu request: 0.1
- cpu limit: 0.1

We have adjusted the limits for the ``service-monitoring`` microservice:

Old values
- cpu request: 0.1

New values
- cpu request: 0.16

### management-ui
We have also updated the docker image for the ``management-ui`` deployment. You need the new version of our ``management-ui`` in order to fully compatible with 3.6.0. This new images is not backwards compatible with Cognigy.AI versions prior to 3.6.0 - so please don't use it with an older version.

## New services
We added the following new folders:
- core/nlp-deployments/sv
- core/nlp-deployments/fi

The additional language we are now offering requires that you re-apply the ``languages`` config-map (located in core/config-maps), before you apply the new NLU services for Finnish & Swedish.

## AWS folder
We have moved certain files which were previously located in core/volume-claims to an AWS folder in the root of this repository. These files are only compatible when deploying our software in an AWS cloud environment and were confusing our customers.

---

# 3.5.2
## Modification of files
The referenced Docker images were changed.

---

# 3.5.1
## Modification of files
The referenced Docker images were changed.

### management-ui
We have also updated the docker image for the ``management-ui`` deployment. The updated ``management-ui`` version is compatible with Cognigy.AI 3.5.1.

---

# 3.5.0
## Modification of files
With this release the referenced Docker images have changed. We also have implemented the following changes for which manual action is required:

### service-handover
The ``service-handover`` deployment was removed from the ``livechat/deployments`` folder and was moved into ``core/deployments`` as this service is now required to run our product and use our new handover interface. This service also needs its own database and secret - hence we have also moved the ``cognigy-service-handover`` secret from ``livechat/secrets`` to ``core/secrets.dist``. You will have to create a new database for ``service-handover`` within your MongoDB and you will have to fill the ``cognigy-service-handover`` secret with the correct connection string. Please consult the ``secrets.md`` file which contains information on how you can create the secret.

### cognigy-rce-credentials secret
We have added a new secret that will be used as a verify token for the ``RingCentral Engage handover integration``. Please follow the steps in the ``secrets.md`` file and create a random token of 32 characters to be used in this secret.

### management-ui
We have also updated the docker image for the ``management-ui`` deployment. The updated ``management-ui`` is only compatible with 3.5.0, so please do not use the new docker image for older versions of Cognigy.AI.

## New services
We added the following new folders:
- core/nlp-deployments/fr

The additional language we are now offering requires that you re-apply the ``languages`` config-map (located in core/config-maps), before you apply the new French NLU services.

---

# 3.4.4
## Modification of files
The referenced Docker images were changed.

---

# 3.4.3
## Modification of files
The referenced Docker images were changed.

## New services
We added the following new folders:
- core/nlp-deployments/ko
- core/nlp-deployments/ar
- core/deployments/service-nlp-ner

The ``service-nlp-ner`` is used for ``entity recognition`` and currently only important for our new languages ``Arabic`` and ``Korean``. There is no need for you to deploy this when you are not utilizing these two new languages! The service will be mandatory in the future, though.

## New limits
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

# 3.4.2
## Modification of files
The referenced Docker images were changed.

---

# 3.4.1
## Modification of files
The referenced Docker images were changed.

## New limits
We have adjusted the limits for the ``service-logs`` microservice:

Old values
- memory request: 60M
- memory limit: 75M

New values
- memory request: 100M
- memory limit: 120M

---

# 3.4.0
## Modification of files
Since we officially added Kubernetes support with our 3.4.0 release of COGNIGY.AI, we changed the structure of the repository a bit. We renamed several things:
- service-nlp-2.0.0-<language>.yaml was renamed to service-nlp-2-0-0-<language>.yaml
- The volume-claim "stateful-mongo-server.yaml" was renamed to "mongo-server.yaml"
- The volume "stateful-mongo-server.yaml" was renamed to "mongo-server.yaml"

In addition, the did the following things:
- We added a ``new secret`` to the deployment ``service-analytics-odata`` so that it can use the new conversations ODATA API.
- We added the environment variable ``NLP_REDIS_LOCK=false`` to all nlp deployments.
- We split the ``GE`` nlp deployment into several languages that now all reside in seperate folders witin the ``core/nlp-deployments`` folder.
- We also changed the config-map ``languages.yaml`` to add ``Portugese support`` and change some settings for ``Arabic``. You therefore need to re-apply this config-map.

## New limits
We also ``changed the limits of all of the deployments`` for our 3.4.0 release based on monitoring results, as well as changed the ``livenessProbe``. 

## Monitoring
We added ``cadvisor support`` for monitoring. To use this, you have to re-apply the config-map ``monitoring/config-maps/prometheus-config.yaml`` and deploy the daemonset ``monitoring/daemonsets/cadvisor.yaml``.

## Management UI
You also need to update the ```Management UI``` to be compatible with 3.4.0. To do this, re-apply the deployment ``management-ui/deployments/management-ui.yaml``
