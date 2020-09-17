# Secrets
Secrets are necessary to provide sensitive information to Kubernetes Pods and their contained containers. We have an ``initialization`` tool which you can learn more about in our ``installation- & dev-ops guide``. If you, at some point, need to manually create a Kubernetes secret, please follow the steps below.

## Generate random values
In order to generate random strings, you can utilize OpenSSL:
```
openssl rand -hex 32
```

This will generate 32 bytes of random values encoded as HEX - these values are safe to use them as passwords, secrets and tokens.

Store the raw-value (plain text values) of your generated secrets somewhere in a safe place. We use a password-manager like KeePassX. In order to fill the actual secret API objects, your secret values now need to get ``base64`` encoded. You can do this with:
```
echo -n <your-secret> | base64 -w0
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

After you have change the contents of a secret, you have to apply the changes to your cluster:
```
kubectl apply -f /path/to/your/secret/some-secret.yml
```