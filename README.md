# NOTE:
We currently work on a first version of the K8s files. Please do not use the manifest files within this repository, yet!


# COGNIGY.AI in k8s

## Kubernetes secrets
### Image pull secret
In order to pull the ``docker images`` from the productive ``docker registry`` of Cognigy, you need to define this an image pull secret: ``cognigy-registry-token``

```
kubectl create secret docker-registry cognigy-registry-token \
    --docker-server=docker.cognigy.com:5000 \
    --docker-username=<username> \
    --docker-password=<password>
```

### Secrets for Deployments / Pods
The following ``secrets`` need to be defined within the ``kubernetes cluster`` so COGNIGY.AI can startup without issues:

| secret name | key | description for value |
| ----------- | --- | --------------------- |
| cognigy-mongo-server | ``mongo-initdb-root-password`` | An alphanumeric string, at least 64 characters |
| cognigy-rabbitmq | ``rabbitmq-password`` | An alphanumeric string, at least 32 characters |
| cognigy-jwt | ``secret`` | An alphanumeric string, at least 128 characters |
| cognigy-smtp | ``security-smtp-password`` | An alphanumeric string, at least 20 characters |
| cognigy-odata | ``odata-super-api-key`` | An alphanumeric string, at least 32 characters |
| cognigy-amazon-credentials | ``amazon-client-id``| The client id from amazon.developers.com |
| cognigy-amazon-credentials | ``amazon-client-secret`` | The client secret from amazon.developers.com |
| cognigy-facebook | ``fb-verify-token`` | An alphanumeric string, at least 32 characters |
| cognigy-service-ai | ``db-password`` | An alphanumeric string, at least 128 characters |
| cognigy-service-alexa-management | ``db-password`` | An alphanumeric string, at least 128 characters |
| cognigy-service-analytics-collector-provider | ``db-password`` | An alphanumeric string, at least 128 characters |
| cognigy-service-analytics-conversation-collector-provider | ``db-password`` | An alphanumeric string, at least 128 characters |
| cognigy-service-api | ``db-password`` | An alphanumeric string, at least 128 characters |
| cognigy-service-database-connections | ``db-password`` | An alphanumeric string, at least 128 characters |
| cognigy-service-endpoints | ``db-password`` | An alphanumeric string, at least 128 characters |
| cognigy-service-flows | ``db-password`` | An alphanumeric string, at least 128 characters |
| cognigy-service-forms | ``db-password`` | An alphanumeric string, at least 128 characters |
| cognigy-service-lexicons | ``db-password`` | An alphanumeric string, at least 128 characters |
| cognigy-service-logs | ``db-password`` | An alphanumeric string, at least 128 characters |
| cognigy-service-nlp | ``db-password`` | An alphanumeric string, at least 128 characters |
| cognigy-service-nlp-connectors | ``db-password`` | An alphanumeric string, at least 128 characters |
| cognigy-service-playbooks | ``db-password`` | An alphanumeric string, at least 128 characters |
| cognigy-service-profiles | ``db-password`` | An alphanumeric string, at least 128 characters |
| cognigy-service-projects | ``db-password`` | An alphanumeric string, at least 128 characters |
| cognigy-service-security | ``db-password`` | An alphanumeric string, at least 128 characters |
| cognigy-service-settings | ``db-password`` | An alphanumeric string, at least 128 characters |

You also need to create a secret for the redis-persistent.conf file in the secrets repository:

```
kubectl create secret generic redis-persistent.conf --from-file=secrets/redis-persistent.conf 
```

## Deploying volumes & volume-claims
### Volumes
Cognigy.AI is currently using shared volumes powered by NFS and a volume where mongodb can persiste data. First we need to create directories on a machine that runes the ``nfs server``:
```
sudo mkdir -p /var/opt/cognigy/data/models
sudo mkdir /var/opt/cognigy/data/config
sudo mkdir /var/opt/cognigy/data/flow-modules
```

Then I am also creating a folder where my ``volume`` for the ``MongoDB`` can persist its data:
```
sudo mkdir -p /var/opt/cognigy/kube-mongo
```

## Creating databases for services
Go into your database container (improve me!).
```
kubectl exec -it <mongo-pod-name> bash

mongo -u admin -p <admin-password> --authenticationDatabase admin
```

To create a database for e.g the ``service-profiles`` service, do the following while you are in the ``Mongo shell``:
```
use service-profiles
db.createUser({
    user: "service-profiles",
    pwd: "zC8RPdCWrbMQkauZfQutgJ86JNyJPXajMMtqk7XTv74Q6w6sqwKD2LyhLL7ZELB7aFcTPUHWuGcSaVfT5gqQfc276sMPFwE6bJrCQJZnZq5E52bbCCa6UcxD5f8GXmLk",
    roles: [
        { role: "readWrite", db: "service-profiles" }
    ]
})

use service-alexa-management
db.createUser({
    user: "service-alexa-management",
    pwd: "REy58sqn8Dh6J5axNuU42ScqWN7cnJwXmcLcW7NDAMpC4DKqLe4Q3E6Xkht5W58stnKY6ajz3WeZYVT8cCeLgZET34wf22nAc65jQ8KZuf2TQ6qA7jsJXcSX6nH7yY9G",
    roles: [
        { role: "readWrite", db: "service-alexa-management" }
    ]
})

use service-analytics-collector-provider
db.createUser({
    user: "service-analytics-collector-provider",
    pwd: "Xt2HmZrTtL4yQPX5NaQzd5LH8f5tWvMbjA9HGNuX4kzcaUAWdZSNBXRs8gKnMsTDJQKM6VMHHuXnwRvkm2QNZddARh4jCeHCaym2eJtubjFbQwvDxtRNsH2sv2DMe87q",
    roles: [
        { role: "readWrite", db: "service-analytics-collector-provider" }
    ]
})

use service-analytics-conversation-collector-provider
db.createUser({
    user: "service-analytics-conversation-collector-provider",
    pwd: "JZATuCYwsmEj4pp8nQZxDSHKHU2NXgGRjZqHuWXLXhbaQMnz2NrVheKP6G8PeUGxDuAgrc6CUqQ94CAzjAyu3x4ncdc9VAw57j5mD3Xuwy2WQ99ckAeEjfSUr4MCR3Kp",
    roles: [
        { role: "readWrite", db: "service-analytics-conversation-collector-provider" }
    ]
})

use service-database-connections
db.createUser({
    user: "service-database-connections",
    pwd: "ZNYBLmgHZrLJKpHt5zGwmuSW84JyPRcT66KFmEUJ8SJ3Q8uWxvdsGxKKcV7wemevEvdjynty7J8vh8gSbpdxY23kBt9FtsHCwXPVSzmnW2cwcpM54qvG2QJamf9XbuKf",
    roles: [
        { role: "readWrite", db: "service-database-connections" }
    ]
})

use service-endpoints
db.createUser({
    user: "service-endpoints",
    pwd: "5nEzYFN4xGj3bEwpYnYjfn7qjzqkPbQEQgmU7fAbcSrtedDyFN7cp6LsK7S7Pam85TUbFkG2vPEZ7GhPMzBQbfgnuecG7swEJPmjUhYayAjzh7zxDjAyMUUXyuGn2ZyF",
    roles: [
        { role: "readWrite", db: "service-endpoints" }
    ]
})

use service-forms
db.createUser({
    user: "service-forms",
    pwd: "p3wqHrRyBh5K8XKxtJ6YfesVZEPDXspZLbaCEgnrYtv6JjTFyTGFqtN7cvDwGGZCkT2pz7k8hL5Yk8Watq7qMjKUDVR4DaBpRWXUUkKWX43VFLfwmXaYjRwywS9dTpbJ",
    roles: [
        { role: "readWrite", db: "service-forms" }
    ]
})

use service-lexicons
db.createUser({
    user: "service-lexicons",
    pwd: "uPyRWnTUeXhff2jch2eAzzBH4Wq5ZMwn2a4s8WcaJbGdbhTs7LJts5b5YWKTWyXaF4ffgdkfxcY2wNDaKScCaD9N8MBhJK8SmGbfdP3NH9GAwVnWUF8ZNSUzWDeGeWr8",
    roles: [
        { role: "readWrite", db: "service-lexicons" }
    ]
})

use service-logs
db.createUser({
    user: "service-logs",
    pwd: "gHFh75ttXTU8p6EzH3VMfDKKGzKP8vYpAUmjxCMMcbry2yjR2AmmdMCRU3DN8D6TW2hdXxSZhs4nMc9Ue7vGPVDEJC7E88MGsPeV9V7RRJmmkDFt6EXApaqHqUR6gz4x",
    roles: [
        { role: "readWrite", db: "service-logs" }
    ]
})

use service-nlp-connectors
db.createUser({
    user: "service-nlp-connectors",
    pwd: "GQNDWLsLbsL83BqJPJLXfPeksAKjhANFnNpaRXkUgctH9ZxegzphF9XAvFvjzhtwgWkYxGqcJEZXYHmkXXYA75rJG9TvuSMjHxWpG7ncFHSRUQzKKcXqCbHXH7z2rUEH",
    roles: [
        { role: "readWrite", db: "service-nlp-connectors" }
    ]
})

use service-playbooks
db.createUser({
    user: "service-playbooks",
    pwd: "BTqacuFhwXKAJSfv9SD77xm2aWZHKn3yDHdUNYuqSm9Y5SS2yTc54N2JcvcWQXn7zqYq9gwykSKZtN8qBLdaax7SA8BqbsefJgarxYFsfXMjsA4CuFcSHTjMVSUtT6qW",
    roles: [
        { role: "readWrite", db: "service-playbooks" }
    ]
})

use service-projects
db.createUser({
    user: "service-projects",
    pwd: "ZMfQAhAR9fTW7nRr38Bur94tVqVtqShHZpK4FdKypxUT7kvQRZqMT6a5dK6SqNkQVdUWywrwxeGHqgEVcDXpGGZNVWyLB5Yx8pNtAgQnBUVDnBbYzVpwKfVMBaXtXmTY",
    roles: [
        { role: "readWrite", db: "service-projects" }
    ]
})

use service-security
db.createUser({
    user: "service-security",
    pwd: "LtTErcw8NayyjR4vL5pfp7Zfse7H5ubhKSF3bHyTyqh3Ej2tJa3vqGU9hevgDfKe3qrnqEp4VUCxgRa6mj27rCgmFEWVkXYM6pnHbpQZpjvUbKrLuAxDPwGUmSRsdKc4",
    roles: [
        { role: "readWrite", db: "service-security" }
    ]
})

use service-settings
db.createUser({
    user: "service-settings",
    pwd: "apM7T3HnLc6RRCJfkVfKYjb6KMM8bJUSXabzLCejr4w5zGpVnzR8N4P8TqBCzc6LxZftdrMGYzsZYxPR8LSpdZe9vWqG9CK27TSWEAYNdwzTgyRQKjX4Xw4WG4BMhHwE",
    roles: [
        { role: "readWrite", db: "service-settings" }
    ]
})

use service-api
db.createUser({
    user: "service-api",
    pwd: "Wygp2H9D9VwEhsS8sha7sZC4ndDWJd2xSGaZZjdp6bPv42r673JHn73k4eYSrpRg5J3YJnunkVYhgRyHWFtHQHASRQWNfSK29KHHF2Hj86W97dqwEYfZyYKpvLVrsVxj",
    roles: [
        { role: "readWrite", db: "service-api" }
    ]
})

use service-ai
db.createUser({
    user: "service-ai",
    pwd: "W4LxTPzM8mLuwVzhU6d7QU7H3rcBvjjpdhCcgPpfK4adnzkVHtqgN5SXKmYaM8MUj8QPK4rkYC5u7mBWR3KLAcnFP6uu9smzKUfSthmhng7hXdZHV3ttBea8uetdQsCv",
    roles: [
        { role: "readWrite", db: "service-ai" }
    ]
})

use service-flows
db.createUser({
    user: "service-flows",
    pwd: "5hp64W7uTR8exEZJwWFspQ3w47zmcbeHmBtRxGUakfj38dAYnqG5MYrd5a9NfqnrbFNWmgdgN4Wd4Q4M9p3Ba7gQULMcyHLa7GvhYANjarAw8ALQxm7PeNQaazqnTybF",
    roles: [
        { role: "readWrite", db: "service-flows" }
    ]
})

use service-nlp
db.createUser({
    user: "service-nlp",
    pwd: "T4G9vegv7HZerQjBQBFV7X7EKsPqz22Vcwcw3mqb4Z7C85mEHgYuCjnSMx85qxGdgSfJPELTHkrtGZqBX3CSY9qQ9cB4euPAAmdMm9QRrddrdzLnKYPCw65VLuYUsZCy",
    roles: [
        { role: "readWrite", db: "service-nlp" }
    ]
})

```


## Deploying everything within the cluster
Now we need to deploy all ``kubernetes API`` objects into the cluster. Here is an example of how to deploy ``redis``:

```
kubectl create -f deployments/stateful-redis.yaml
kubectl create -f services/stateful-redis.yaml
```