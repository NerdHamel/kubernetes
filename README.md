# COGNIGY.AI in k8s
This is the official Kubernetes (``k8s``) manifest repository for COGNIGY.AI. The following notes should give you a basic understand on how our product can be deployed on top of Kubernetes.

The API-objects we are using are tested with Kubernetes 1.9 - everything should work with more modern version of K8s as well.

## Introduction
This repository has the following folder-structure:
```
| - core
| --- config-maps
| --- deployments
| --- nlp-deployments
| ------- de
| ------- en
| ------- ge
| --- ingress
| --- reverse-proxy.dist
| --- secrets.dist
| --- services
| --- stateful-deployments
| --- volume-claims
| --- volumes.dist
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
|
| - monitoring
| --- config-maps
| --- deployments
| --- secrets.dist
| --- services
| --- volume-claims
| --- volumes.dist
```

The main folders are ``core``, ``livechat``, ``management-ui`` and ``monitoring``. All of these direcotries potential contain sub-folders which contain K8s API objects of various sorts, such as:
- deployments
- ingress objects
- secrets
- services
- volume-claims
- volumes
- config-maps

We selected this folder structure to make it a bit more easy for you to understand and deploy our application. The ``core`` folder contains the actual API objects you will need to deploy a fully functional COGNIY.AI system. The other directories within the root of this repository contain additional software that can be installed side-by-side with COGNIGY.AI. Those additional tools will most likely not work without running our core product.

## Setup
This section will guide you through the process of setting up your COGNIGY.AI installation. You will no longer need it, once your initial deployment succeeded.

### Config map
---
COGNIGY.AI uses K8s' concept of config-maps for its full configuration. The directory ``core/config-maps`` contains all config-maps which you can edit and modify to your needs.

You will definitely need to modify the ``BASE_URL`` entries to match the URLs you use in your application (e.g. ui.company.com). After you are done with your modifications, deploy those within your K8s cluster:
```
kubectl apply -f core/config-maps
```

### Image Pull Secret
---
In order to pull the required ``docker images`` from Cognigy's production registry, you need to define a so-called ``image pull secret``. Kubernetes will use this secret in order to authenticate against our docker registry in order to retrieve docker images for a release.

We will provide the necessary ``username:password`` pair when you obtain your COGNIGY.AI license. In order to create the image pull secret, issue the following command:
```
kubectl create secret docker-registry cognigy-registry-token \
    --docker-server=docker.cognigy.com:5000 \
    --docker-username=<username> \
    --docker-password='<password>'
```

### Secrets
---
COGNIGY.AI heavily uses secrets, a K8s API object that allows you to store secret information in a secure way within your cluster. Information stored within secrets are encrypted and stored within ``etcd`` a key-value store kubernetes uses internally. Containers can mount secrets and access information stored within secrets. Kubernetes will decrypt information within secrets during runtime and make the plain-text information accessible to a running container.

The ``core/secrets.dist`` folder contains empty API objects you can use to prepare your correct secrets and finally apply them to your cluster.

We have created a tool that will create random credentials for most of the required secrets. You can either got with our tool, or fill all secrets on your own.

In order to use the tool, download it, make it executable and run it within the root of this repository:
```
wget https://github.com/Cognigy/kubernetes-tools/releases/download/0.1.0/initialization
chmod +x ./initialization

./initialization
```

This will create a copy of your ``core/secrets.dist`` folder named ``core/secrets``. It will contain completely finished objects you can deploy into your cluster using:
```
kubectl apply -f core/secrets
```

Furthermore, it will create a ``dbinit.js`` file which you can use to create all required databases and users within your ``MongoDB deployment``.

### Storage
#### Introduction
---
COGNIGY.AI needs to persist data in order to work properly. We e.g. have dependencies against MongoDB and Redis. Both software products are databases which need to persist their data in a reliable and persistent way.

Kubernetes has a concept of ``Persistent Volumes (PV)`` and ``Persistent Volume Claims (PVC)``. A Pod can express its need for persistent storage using a PVC. The PVC gets bound to a PV and can use a certain amount of the storage available from a PV.

Cluster administrators need to configure PVs and make them available within the cluster. There are multiple ways on how this can be achieved and it is mostly dependent on the cloud provider and the infrastructure available. If a Cognigy.AI installation gets spawned on ``AWS``, services such as ``EBS`` and ``EFS`` can be used. In a on-premise scenario, the easiest way to get started ist to use ``local volumes`` for performance critical PVs (e.g. databases) and ``NFS backed`` PVs for non-performance critical situations.

All information will be stored on one of the Kubernetes hosts - this is not optimal but a starting point. So let's first create the folders where the actual data will get persisted:
```
sudo mkdir -p /var/opt/cognigy/data/models
sudo mkdir /var/opt/cognigy/data/flow-modules
```

Please also create the following additional directories where MongoDB and Redis (persistent) can store their data:
```
sudo mkdir -p /var/opt/cognigy/mongo
sudo mkdir -p /var/opt/cognigy/redis-persistent
```

#### NFS configuration
If you want to utilize NFS because you are e.g. not in a cloud environment and can't use services such as ``EBS`` or ``EFS``, you first need to install the ``nfs server`` component on the machine where the data gets finally persisted.

If you are using a Debian based OS, the nfs server can be installed using the following command:
```
sudo apt get update
sudo apt get install nfs-kernel-server
```

After the package was installed, you will now need to write a configuration file, which tells the NFS server the locations within the local file system it should offer on the network. Open the following file using a text editor: ``/etc/exports`` and place the following content into the file:
```
# /etc/exports: the access control list for filesystems which may be exported
#		to NFS clients.  See exports(5).
#
# Example for NFSv2 and NFSv3:
# /srv/homes       hostname1(rw,sync,no_subtree_check) hostname2(ro,sync,no_subtree_check)
#
# Example for NFSv4:
# /srv/nfs4        gss/krb5i(rw,sync,fsid=0,crossmnt,no_subtree_check)
# /srv/nfs4/homes  gss/krb5i(rw,sync,no_subtree_check)
#
/var/opt/cognigy/data/models <ip>(rw,fsid=0,insecure,no_subtree_check,sync)
/var/opt/cognigy/data/flow-modules <ip>(rw,fsid=1,insecure,no_subtree_check,sync)
```

Replace the ``<ip>`` part with a valid CIDR-block, e.g. the one from your internal network. Machines within this address block will have access to the files shared through NFS. Also be sure, that you are adding an entry per folder you want to share - adjust the ``fsid`` and increment it on any additional entry.

After you wrote the changes to disk, let's restart the NFS server in order to re-load its configuration. This can be achived through the following command on Debian based operating systems:
```
sudo service nfs-kernel-server restart
```


#### Persistent Volumes
---
Persistent volumes (PVs) allow containerized applications to store their state (files, configuration, cache) in a persistent way either on the host or somewhere in the cloud. In order to run COGNIGY.AI you need to create persistent volumes so pods (defined by deployments) can mount persistent volumes by issuing so-called ``persistent volume claims``.

Have a look at the contents of ``core/volumes.dist`` and inspect all of the following PVs:
- flow-modules-nfs.yaml
- nlp-config-nfs.yaml
- nlp-models-nfs.yaml
- redis-persistent.yaml
- stateful-mongo-server.yaml

The reason why we named this directory ``.dist`` is the fact, that you definitely need to change these files before you apply them to your cluster. You should not update those files in the future when Cognigy provides new files for a new release. Simply create a copy of the folder and name it ``volumes``. Do all of your modifications within the ``volumes`` folder and leave ``volumes.dist`` untouched.

We essentially have grouped them and are using ``NFS`` for some of those volumes (they have the ``-nfs`` prefix in their names). The other volumes for ``redis-persistent`` and ``mongo`` use local volumes that are persistent on one of the hosts directly.

Be sure to exchange the ``server/path`` pair within the ``-nfs``-prefixed files as well as the ``machine-name`` (#change me!) for your local volumes.

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

We need to connect to our ``MongoDB`` deployment and create several databases and users for those. Lukily our ``initialization`` tool has you covered! If you used it to generate ``core/secrets``, you will also have a ``dbinit.js`` file.

Let's first connect to our ``MongoDB`` instance. We first need to open a mongo shell in order to run commands against it. Let's first get the kubernetes pod name of your MongoDB:
```
kubectl get po
```

Find the actual Pod name of your MongoDB copy and copy it. Then execute the following command and replace ``<mongo-pod-name>`` as well as ``<mongo-admin-password>``:
```
kubectl exec -it <mongo-pod-name> mongo -u admin -p <mongo-admin-password> --authenticaitonDatabase admin
```

You should now see the mongo client prompt. Copy the whole contents of the ``dbinit.js`` file which was generated by our ``initialization`` tool and paste it into the Mongo shell.

After you created all of the databases within MongoDB, quite the shell by typing ``exit``. You can now apply our main ``deployment`` objects by executing:
```
kubectl apply -f core/services/
kubectl apply -f core/deployments/
```

### Availability of your installation
COGNIGY.AI exposes several software components which need to be available from outside of your installation. These are services such as ``endpoint``, ``ui`` and ``api``. Our customers use these services to build new Conversational AIs (ui, api) and make them available to other platforms like ``Facebook Messenger``.

In the folder ``core/reverse-proxy.dist``, you will find the necessary API objects to expose COGNIGY.AI. You should therefore rename the folder to ``reverse-proxy``, since we need to make some changes.

We use a modern ``Ingress Controller`` which allows external web-traffic to reach certain software components within your cluster - it's called Traefik. If you do not have your own reverse proxy set up, then you can deploy Traefik. Do this by first changing the external IP address in the file ``core/reverse-proxy/services/traefik.yaml`` to be the external IP of your server, and afterwards, you can run the two commands below to deploy Traefik:

```
kubectl apply -f core/reverse-proxy/services/
kubectl apply -f core/reverse-proxy/deployments/
```

The Ingress objects stored within ``core/reverse-proxy/ingress`` control how the reverse proxy can reach your internal services and can make them accessible. If you use Traefik as the reverse proxy, then you can simply apply these files to make COGNIGY.AI accessible. If you are using a different reverse proxy, then you should modify them to work with this reverse proxy (e.g. modify the ingress annotation class).

In order to deploy all of your ingress configurations execute:

```
kubectl apply -f core/ingress/
```