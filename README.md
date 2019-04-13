# Todo
- add new NLP services
- check volumes / volume-claims
- add new execution service
- check securityContext NLP


# COGNIGY.AI in k8s
This is the official Kubernetes (``k8s``) manifest repository for COGNIGY.AI. The following notes should give you a basic understand on how our product can be deployed on top of Kubernetes.

The API-objects we are using are tested with Kubernetes 1.9 - everything should work with more modern version of K8s as well.

## Introduction
This repository has the following folder-structure:
```
| - core
| --- config-maps
| --- deployments
| --- ingress
| --- secrets.dist
| --- services
| --- stateful-deployments
| --- volume-claims
| --- volumes
|
| - livechat
| --- deployments
| --- ingress
| --- secrets
| --- services
|
| - management-ui
| --- deployments
| --- services
```

The main three folders are ``core``, ``livechat`` and ``management-ui``. All of these directories contain sub-folders which contain K8s API objects of various sorts, such as:
- deployments
- ingress objects
- secrets
- services
- volume-claims
- volumes
- config-maps

We selected this folder structure to make it a bit more easy for you to understand and deploy our application. The ``core`` folder contains the actual API objects you will need to deploy a fully functional COGNIY.AI system. The other two folders within the root of this repository contain additional software that can be instaled side-by-side with COGNIGY.AI. Those additional tools will not be functional without a working COGNIGY.AI deployment.

## Setup
This section will guide you through the process of setting up your COGNIGY.AI installation. Will no longer need it, once your initial deployment succeeded.

### Config map
---
COGNIGY.AI uses K8s' concept of config-maps for its full configuration. The directory ``core/config-maps`` contains all config-maps which you can edit and modify to your needs.

After you are done with your modifications, deploy those within your K8s cluster:
```
kubectl apply -f core/config-maps
```

### Image Pull Secret
---
In order to pull the required ``docker images`` from Cognigy's production registry, you need to define a so-called ``image pull secret``. Kubernetes will use this secret in order to authenticate against our docker registry in order to retrieve docker images for a release.

We will provide the necessary ``username:password`` pair when you obtain your COGNIGY.AI license.

In order to create the image pull secret, issue the following command:
```
kubectl create secret docker-registry cognigy-registry-token \
    --docker-server=docker.cognigy.com:5000 \
    --docker-username=<username> \
    --docker-password=<password>
```

### Secrets
---
COGNIGY.AI heavily uses secrets, a K8s API object that allows you to store secret information in a secure way within your cluster. Secrets will be made accessible to our software during runtime.

The ``core/secrets.dist`` folder contains empty API objects you can use to prepare your correct secrets and finally deploy them. The first step within preparing your secrets is to rename the ``secrets.dist`` folder to ``secrets``. We have a ``.gitignore`` file within this repository which avoids that you accidentally push your final secrets to the public world.

Let's have a look at one of these files:
```
apiVersion: v1
kind: Secret
metadata:
    name: cognigy-facebook
type: Opaque
data:
    # -> base64 encoded
    fb-verify-token: 
```

The secret has some meta-data and a data part which contains the actual secret. In this example, the key is ``fb-verify-token`` and the actual value was not select. You can now create a random value for this using OpenSSL:
```
openssl rand -hex 32
```

This will genreate 32 bytes of random values encoded as HEX - these values are safe to use them as passwords, secrets and tokens. The secret API objects contain suggestions on what length should be used for best performance/security.

Store the raw-value (plain text values) of your generated secrets somewhere in a safe place. We use a password-manager like KeyPassX. In order to fill the actual secret API objects, your secret values now need to get ``base64`` encoded. You can do this with:
```
echo <your-secret> -n | base64 -w0
```

Take the value that was created and store it within your secret API object as followed:
```
apiVersion: v1
kind: Secret
metadata:
    name: cognigy-facebook
type: Opaque
data:
    # -> base64 encoded
    fb-verify-token: MWNmOTVlMmI5Nzg0YjQ0MWUyNTkxNTMyOGZiMzYzZjk4MzY3Nzc3YTg2MjI0ZjY3ZDI1YzQ1ZDM4Mjc1NjVlOSAtbgo=
```

You can now use the same procedure for all files within your ``core/secrets`` directory and finally deploy those API objects into your cluster issuing:
```
kubectl apply -f core/secrets
```

We have one special secret which is not create from these API objects - the configuration for ``redis persistent``. To create this secret, issue the following command:
```
kubectl create secret generic redis-persistent.conf --from-file=secrets/redis-persistent.conf 
```

### Storage
#### Introduction
---
COGNIGY.AI needs to persist data in order to work properly. The simplest way to persist data is by using NFS as a volume-provider within your Kubernetes cluster.

Please bare in mind, that the performance of your NFS is crucial in order to have a high performance COGNIGY.AI installation! Don't put your NFS onto a slow network!

We usually setup a server and create the following directories in which NFS can store the actual data:
```
sudo mkdir -p /var/opt/cognigy/data/models
sudo mkdir /var/opt/cognigy/data/config
sudo mkdir /var/opt/cognigy/data/flow-modules
```

If you NFS is fast, you can also utilize it for MongoDB and Redis (persistent) if you deploy data-stores in a fully containerized way as well. In this case, we would create additional directories where those data-stores can persist their data:
```
sudo mkdir -p /var/opt/cognigy/mongo
sudo mkdir -p /var/opt/cognigy/redis-persistent
```

#### Persistent Volumes
---
Persistent volumes (PVs) allow containerized applications to store their state (files, configuration, cache) in a persistent way either on the host or somewhere in the cloud. In order to run COGNIGY.AI you need to create persistent volumes so deployments (and pods) can mount persistent volumes by issuing so-called ``persistent volume claims``.

Have a look at the contents of ``core/volumes`` and inspect all of the following PVs:
- flow-modules-nfs.yaml
- nlp-config-nfs.yaml
- nlp-models-nfs.yaml
- redis-persistent.yaml
- stateful-mongo-server.yaml
--> add new NLP local volume!

You will need to adjust the ``server`` and the ``path`` part within the NFS configuration within all of these PVs objects. The value of the ``storage`` capacity can also be adjusted, in case you need more for your use-case.

If you finished all of your adjustments, deploy the PV objects into your cluster:
```
kubectl apply -f core/volumes/
```

#### Persistent Volume Claims
Persistent volume claims (PVCs) are the actual way how Pods express their needs for storage. They claim a part of a PV. Kubernetes will reserve this block of the whole PV specifically for them!

All of the PVC objects are within ``core/volume-claims``. You might want to adjust the ``storage`` request value in case you also modified the PV objects. Please ensure that the storage request is actually lower than what your PVs offer.

If you are done with your modifications, deploy the objects using:
```
kubectl apply -f core/volume-claims/
```

#### Stateful deployments
COGNIGY.AI is dependent on MongoDB, Redis, a second Redis which persists data and RabbitMQ. Those components need to be available in order so COGNIGY.AI can be deployed and started.

To make it easier to separate our software from those dependencies, we created the ``core/stateful-deployments`` which only contain deployment objects for databases and the message broker. Feel free to have a look at those files.

If you are done, deploy those objects using:
```
kubectl apply -f core/stateful-deployments/
```

#### Initializing MongoDB
After you have deployed all of the stateful deployments, wait until all of your Pods are up and running.

We now need to create various databases within MongoDB and create users for the individual databases. In order to create those databases and users, let's connect to our running MongoDB by executing the ``mongo`` (client) command within the MongoDB pod. In order to do that, first get the name/id of your MongoDB pod:
```
kubectl get po
```

Find the actual Pod name of your MongoDB copy and copy it. Then execute the following command and replace ``<mongo-pod-name>`` as well as ``<mongo-admin-password>``:
```
kubectl exec -it <mongo-pod-name> mongo -u admin -p <mongo-admin-password> --authenticaitonDatabase admin
```

You should now see the mongo client prompt. In order to create all databases and users, execute the following command for all of the databases you see within the list below:
```
use service-profiles
db.createUser({
    user: "service-profiles",
    pwd: "zC8RPdCWrbMQkauZfQutgJ86JNyJPXajMMtqk7XTv74Q6w6sqwKD2LyhLL7ZELB7aFcTPUHWuGcSaVfT5gqQfc276sMPFwE6bJrCQJZnZq5E52bbCCa6UcxD5f8GXmLk",
    roles: [
        { role: "readWrite", db: "service-profiles" }
    ]
})
```

Be sure to replace 'service-profiles' with the actual name from the list below and also replace the password (the part after 'pwd') with the actual clear-type (not the base64 encoded one) password you have generated earlier in the Secrets step (the ones you might have stored in your password manager).

An example for ``service-ai`` from the list would look like:
```
use service-ai
db.createUser({
    user: "service-ai",
    pwd: "my-super-secure-service-ai-password",
    roles: [
        { role: "readWrite", db: "service-ai" }
    ]
})
```

Execute the command above for every element within the following list:

| database/user name | Optional notes |
| ------------------ | ----- |
| service-ai | - |
| service-alexa-management | - |
| service-analytics-collector-provider | Used by ``service-analytics-collecter`` as well as ``service-analytics-provider `` |
| service-analytics-conversation-collector-provider | Used by ``service-analytics-conversation-collector`` as well as ``service-analytics-conversation-provider`` |
| service-api | - |
| service-custom-modules | - |
| service-database-connections | - |
| service-endpoints | - |
| service-files | - |
| service-flows | - |
| service-forms | - |
| service-lexicons | - |
| service-logs | - |
| service-nlp | - |
| service-nlp-connectors | - |
| service-playbooks | - |
| service-profiles | - |
| service-projects | - |
| service-secrets | - |
| service-security | - |
| service-settings | - |

If you want to use the additional ``livechat`` product, you also need to create the database/user for:

| database/user name | Optional notes |
| ------------------ | ----- |
| service-handover | - |

After you created all of the databases within MongoDB, quite the shell by typing ``exit``. You can now apply our main ``deployment`` objects by executing:
```
kubectl apply -f core/deployments/
kubectl apply -f core/services/
```

### Availability of your installation
COGNIGY.AI exposes several software components which need to be available from outside of your installation. These are services such as ``endpoint``, ``ui`` and ``api``. Our customers use these services to build new Conversational AIs (ui, api) and make them available to other platforms like ``Facebook Messenger``.

We use a modern ``Ingress Controller`` which allows external web-traffic to reach certain software components within your cluster - it's called Traefik. Traefik will be deployed as part of cognigy. Its API object resides within ``core/deployments``.

The Ingress objects stored within ``core/ingress`` control how Traefik can reach your internal services and can make them accessible. Traefik will also take care about TLS/SSL termination etc.

In order to deploy all of your ingress configurations execute:
```
kubectl apply -f core/ingress/
```