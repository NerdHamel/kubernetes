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
wget https://github.com/Cognigy/kubernetes-tools/releases/download/v2.0.0/initialization-linux
chmod +x ./initialization-linux
./initialization-linux --generate
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
sudo chown -R 1000:1000 /var/opt/cognigy/flow-modules
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

### 4.2 Custom theme
**Configuring a theme**
```
cd /path/to/your/theme

kubectl create configmap theme-logo.png --from-file ./logo.png
kubectl create configmap theme-logo-primary.png --from-file ./logo_primary.png
kubectl create configmap theme-logo-square.png --from-file ./logo_square.png

kubectl create configmap theme-main-background.png --from-file ./main_background.png
kubectl create configmap theme-static-content3.png --from-file ./static_content3.png
kubectl create configmap theme-static-content2.png --from-file ./static_content2.png
kubectl create configmap theme-static-content1.png --from-file ./static_content1.png

kubectl create configmap theme-custom-config.json --from-file custom_config.json
```

**service-ui patch to apply the theme**
```
- op: add
  path: /spec/template/spec/containers/0/env
  value:
    - name: FEATURE_USE_WHITELABELING
      value: "true"

- op: add
  path: /spec/template/spec/containers/0/volumeMounts
  value:
    - name: theme-custom-config-json
      mountPath: /app/build/custom/theme/custom_config.json
      subPath: custom_config.json
    - name: theme-logo-png
      mountPath: /app/build/custom/theme/logo.png
      subPath: logo.png
    - name: theme-logo-primary-png
      mountPath: /app/build/custom/theme/logo_primary.png
      subPath: logo_primary.png
    - name: theme-logo-square-png
      mountPath: /app/build/custom/theme/logo_square.png
      subPath: logo_square.png
    - name: theme-main-background-png
      mountPath: /app/build/custom/theme/main_background.png
      subPath: main_background.png
    - name: theme-static-content1-png
      mountPath: /app/build/custom/theme/static_content1.png
      subPath: static_content1.png
    - name: theme-static-content2-png
      mountPath: /app/build/custom/theme/static_content2.png
      subPath: static_content2.png
    - name: theme-static-content3-png
      mountPath: /app/build/custom/theme/static_content3.png
      subPath: static_content3.png

- op: add
  path: /spec/template/spec/volumes
  value:
    - name: theme-custom-config-json
      configMap:
        name: theme-custom-config.json
    - name: theme-logo-png
      configMap:
        name: theme-logo.png
    - name: theme-logo-primary-png
      configMap:
        name: theme-logo-primary.png
    - name: theme-logo-square-png
      configMap:
        name: theme-logo-square.png
    - name: theme-main-background-png
      configMap:
        name: theme-main-background.png
    - name: theme-static-content1-png
      configMap:
        name: theme-static-content1.png
    - name: theme-static-content2-png
      configMap:
        name: theme-static-content2.png
    - name: theme-static-content3-png
      configMap:
        name: theme-static-content3.png
```

**Loading your additional patch**
```
# ui deployment for custom theme
- target:
    group: apps
    version: v1
    kind: Deployment
    name: service-ui
  path: overlays/deployments/service-ui_patch.yaml
```

### 5.2 Retrieving the update
**Make local repository current**
```
git fetch origin
git checkout tags/v4.0.0
```