# Initializing MongoDB Replicaset
When starting MongoDB for the first time, the one member replicaset has to be initialized. To do this, first exec into the mongo container:

```
kubectl exec -it deployment/mongo-server bash
```

The next step is to login with the admin user. To do this, run the command below:

```
mongo -u admin -p $MONGO_INITDB_ROOT_PASSWORD
```

We can now initialize the replicaset with the following command:

```
rs.initiate({
    _id: "rs0",
    members: [
        {
            _id: 0,
            host: "127.0.0.1:27017"
        }
    ]
})
```