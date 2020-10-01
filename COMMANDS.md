# Introduction
This file contains commands which are referenced in our official `Installation and Dev-Ops guide` for Cognigy.AI version 4.X. Feel free to use these commands and copy/paste them for your convenience. The commands are listed in order and referenced based on the listings from the installation guide.

# Cheatsheet
## Chapter 3, Installation
### 3.1 Cognigy.AI manifest files
**Cloning the Kubernetes repository**
```
git clone https://github.com/Cognigy/kubernetes.git
```

### 3.1.2 Using templates
**Preparing the files for a Cognigy.AI environment**
```
cd kubernetes.git
cd core
chmod +x make_environment.sh
./make_environment.sh development
```

### 3.2 Configuring container registry access
**Creating the image pull secret**
```
kubectl create secret docker-registry cognigy-registry-token \
--docker-server=docker.cognigy.com:5000 \
--docker-username=<your-username> \
--docker-password='<your-password>'
```

### 3.3 Secrets
**Creating random secrets for Kuberentes**
```
cd kubernetes.git/core/<environment>/product
wget https://github.com/Cognigy/kubernetes-tools/releases/download/v2.0.0/initialization
chmod +x ./initialization
./initialization --generate
```

**Creating secrets in your Kubernetes cluster**
```
kubectl apply -f secrets
```

### 3.4.2 Storage for single server installations
**Creating directories for local storage**
```
sudo mkdir -p /var/opt/cognigy/mongodb
sudo mkdir -p /var/opt/cognigy/redis-persistent
sudo mkdir -p /var/opt/cognigy/flow-modules

sudo chown -R 999:999 /var/opt/cognigy/mongodb
```

### 3.5 Database, Message-Broker and Cache
**Deploying our products dependencies**
```
cd kubernetes.git/core/<environment>/dependencies
kubectl apply -k ./
```

**Initializing a replica-set and creating databases with users**
```
kubectl exec -it deployment/mongo-server -- sh
mongo -u admin -p $MONGO_INITDB_ROOT_PASSWORD --authenticationDatabase admin

rs.initiate({
    _id: "rs0",
    members: [
        {
            _id: 0,
            host: "127.0.0.1:27017"
        }
    ]
})

// wait a couple of seconds and hit enter, your command promt should change
// from "SECONDARY" to "PRIMARY"

// insert contents of your "dbinit.js" script, located next to your 'secrets'
// folder
```

### 3.6 Installing Cognigy.AI
**Checking the state of your cluster**
```
kubectl get pv
kubectl get pvc
kubectl get deployments
```

**Deploying Cognigy.AI by using kustomize**
```
cd kubernetes.git/core/<environment>/product
kubectl apply -k ./
```

**Monitoring the deployment**
```
watch -d kubectl get deployment
```

### 3.7 Retrieve login credentials
**Retrieving credentials from service-security logs**
```
kubectl logs -f --tail 100 deployment/service-security
```

### 5.2 Retrieving the update
**Make local repository current**
```
git fetch origin
git checkout tags/v4.0.0
```