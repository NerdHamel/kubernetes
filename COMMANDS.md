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

---
## Chapter 4, Configuration
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

kubectl create configmap theme-android-icon-192x192.png --from-file android-icon-192x192.png
kubectl create configmap theme-apple-icon-57x57.png --from-file apple-icon-57x57.png
kubectl create configmap theme-apple-icon-60x60.png --from-file apple-icon-60x60.png
kubectl create configmap theme-apple-icon-72x72.png --from-file apple-icon-72x72.png
kubectl create configmap theme-apple-icon-76x76.png --from-file apple-icon-76x76.png
kubectl create configmap theme-apple-icon-114x114.png --from-file apple-icon-114x114.png
kubectl create configmap theme-apple-icon-120x120.png --from-file apple-icon-120x120.png
kubectl create configmap theme-apple-icon-144x144.png --from-file apple-icon-144x144.png
kubectl create configmap theme-apple-icon-152x152.png --from-file apple-icon-152x152.png
kubectl create configmap theme-apple-icon-180x180.png --from-file apple-icon-180x180.png
kubectl create configmap theme-favicon.ico --from-file favicon.ico
kubectl create configmap theme-favicon-16x16.png --from-file favicon-16x16.png
kubectl create configmap theme-favicon-32x32.png --from-file favicon-32x32.png
kubectl create configmap theme-favicon-96x96.png --from-file favicon-96x96.png
kubectl create configmap theme-favicon-256x256.png --from-file favicon-256x256.png
kubectl create configmap theme-ms-icon-70x70.png --from-file ms-icon-70x70.png
kubectl create configmap theme-ms-icon-144x144.png --from-file ms-icon-144x144.png
kubectl create configmap theme-ms-icon-150x150.png --from-file ms-icon-150x150.png
kubectl create configmap theme-ms-icon-310x310.png --from-file ms-icon-310x310.png
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
    # favicon, android
    - name: theme-android-icon-192x192.png
      mountPath: /app/build/custom/theme/favicon/android-icon-192x192.png
      subPath: android-icon-192x192.png
    # favicon, apple
    - name: theme-apple-icon-57x57.png
      mountPath: /app/build/custom/theme/favicon/apple-icon-57x57.png
      subPath: apple-icon-57x57.png
    - name: theme-apple-icon-60x60.png
      mountPath: /app/build/custom/theme/favicon/apple-icon-60x60.png
      subPath: apple-icon-60x60.png
    - name: theme-apple-icon-72x72.png
      mountPath: /app/build/custom/theme/favicon/apple-icon-72x72.png
      subPath: apple-icon-72x72.png
    - name: theme-apple-icon-76x76.png
      mountPath: /app/build/custom/theme/favicon/apple-icon-76x76.png
      subPath: apple-icon-76x76.png
    - name: theme-apple-icon-114x114.png
      mountPath: /app/build/custom/theme/favicon/apple-icon-114x114.png
      subPath: apple-icon-114x114.png
    - name: theme-apple-icon-120x120.png
      mountPath: /app/build/custom/theme/favicon/apple-icon-120x120.png
      subPath: apple-icon-120x120.png
    - name: theme-apple-icon-144x144.png
      mountPath: /app/build/custom/theme/favicon/apple-icon-144x144.png
      subPath: apple-icon-144x144.png
    - name: theme-apple-icon-152x152.png
      mountPath: /app/build/custom/theme/favicon/apple-icon-152x152.png
      subPath: apple-icon-152x152.png
    - name: theme-apple-icon-180x180.png
      mountPath: /app/build/custom/theme/favicon/apple-icon-180x180.png
      subPath: apple-icon-180x180.png
    # favicon, browsers
    - name: theme-favicon.ico
      mountPath: /app/build/custom/theme/favicon/favicon.ico
      subPath: favicon.ico
    - name: theme-favicon-16x16.png
      mountPath: /app/build/custom/theme/favicon/favicon-16x16.png
      subPath: favicon-16x16.png
    - name: theme-favicon-32x32.png
      mountPath: /app/build/custom/theme/favicon/favicon-32x32.png
      subPath: favicon-32x32.png
    - name: theme-favicon-96x96.png
      mountPath: /app/build/custom/theme/favicon/favicon-96x96.png
      subPath: favicon-96x96.png
    - name: theme-favicon-256x256.png
      mountPath: /app/build/custom/theme/favicon/favicon-256x256.png
      subPath: favicon-256x256.png
    # favicon, ms browsers
    - name:  theme-ms-icon-70x70.png
      mountPath: /app/build/custom/theme/favicon/ms-icon-70x70.png
      subPath: ms-icon-70x70.png
    - name:  theme-ms-icon-144x144.png
      mountPath: /app/build/custom/theme/favicon/ms-icon-144x144.png
      subPath: ms-icon-144x144.png
    - name:  theme-ms-icon-150x150.png
      mountPath: /app/build/custom/theme/favicon/ms-icon-150x150.png
      subPath: ms-icon-150x150.png
    - name:  theme-ms-icon-310x310.png
      mountPath: /app/build/custom/theme/favicon/ms-icon-310x310.png
      subPath: ms-icon-310x310.png


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
    # android
    - name: theme-android-icon-192x192.png
      configMap:
        name: theme-android-icon-192x192.png
    # apple
    - name: theme-apple-icon-57x57.png
      configMap:
        name: theme-apple-icon-57x57.png
    - name: theme-apple-icon-60x60.png
      configMap:
        name: theme-apple-icon-60x60.png
    - name: theme-apple-icon-72x72.png
      configMap:
        name: theme-apple-icon-72x72.png
    - name: theme-apple-icon-76x76.png
      configMap:
        name: theme-apple-icon-76x76.png
    - name: theme-apple-icon-114x114.png
      configMap:
        name: theme-apple-icon-114x114.png
    - name: theme-apple-icon-120x120.png
      configMap:
        name: theme-apple-icon-120x120.png
    - name: theme-apple-icon-144x144.png
      configMap:
        name: theme-apple-icon-144x144.png
    - name: theme-apple-icon-152x152.png
      configMap:
        name: theme-apple-icon-152x152.png
    - name: theme-apple-icon-180x180.png
      configMap:
        name: theme-apple-icon-180x180.png
    # browsers
    - name: theme-favicon.ico
      configMap:
        name: theme-favicon.ico
    - name: theme-favicon-16x16.png
      configMap:
        name: theme-favicon-16x16.png
    - name: theme-favicon-32x32.png
      configMap:
        name: theme-favicon-32x32.png
    - name: theme-favicon-96x96.png
      configMap:
        name: theme-favicon-96x96.png
    - name: theme-favicon-256x256.png
      configMap:
        name: theme-favicon-256x256.png
    # ms browsers
    - name: theme-ms-icon-70x70.png
      configMap:
        name: theme-ms-icon-70x70.png
    - name: theme-ms-icon-144x144.png
      configMap:
        name: theme-ms-icon-144x144.png
    - name: theme-ms-icon-150x150.png
      configMap:
        name: theme-ms-icon-150x150.png
    - name: theme-ms-icon-310x310.png
      configMap:
        name: theme-ms-icon-310x310.png
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

---
## Chapter 5, Updating
### 5.2 Retrieving the update
**Make local repository current**
```
git fetch origin
git checkout tags/v4.0.0
```

---
## Chapter 6, Cognigy Live Agent
### 6.2.2 Using templates
**Preparing the files for a Cognigy Live Agent installation**
```
cd kubernetes.git
cd live-agent
chmod +x make_environment.sh
./make_environment.sh development
```

### 6.2.3 Secrets
**Preparing the Live Agent secrets for your installation.**
```
cd kubernetes.git/live-agent/<environment>
cp -R secrets.dist secrets
```

**Generating safe values for your Live Agent secrets.**
```
wget https://github.com/Cognigy/kubernetes-tools/releases/download/v2.0.0/initialization-linux
chmod +x ./initialization-linux
./initialization-linux --generate
```

**Creating Live Agent secrets in your Kubernetes cluster**
```
kubectl apply -f secrets
```

### 6.2.4 Storage
**Creating additional database and user for Live Agent.**
```
kubectl exec -it deployment/mongo-server -- sh
mongo -u admin -p $MONGO_INITDB_ROOT_PASSWORD --authenticationDatabase admin

// insert contents of your "dbinit.js" script, located next to your 'secrets' folder
```

### 6.2.5 Patch files
**Applying Cognigy Live Agent files in order to initiate initial deployment.**
```
cd kubernetes.git/live-agent/<environment>
kubectl apply -k ./
```

**Updating Cognigy.AI configuration and ensure that services have correct configuration.**
```
cd kubernetes.git/core/<environment>/product
kubectl apply -k ./

kubectl rollout restart deployments/service-api
kubectl rollout restart deployments/service-ui
kubectl rollout restart deployments/service-handover
```