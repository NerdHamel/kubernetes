# Secrets
This directory contains raw secrets which you need to modify in order to deploy them to your k8s cluster. You should first create a copy of the whole folder and name it ``core/secrets``. Please apply all your modifications to the files within ``core/secrets`` and leave the files within the current directory untouched.

We have created a tool which helps you to automatically created all required secrets and initialize them with random and secure credentials. Have a look at the main ``README.md`` within the root of this repository.

## Generate random values
In order to generate random strings, you can utilize OpenSSL:
```
openssl rand -hex 32
```

This will genreate 32 bytes of random values encoded as HEX - these values are safe to use them as passwords, secrets and tokens. The secret API objects contain suggestions on what length should be used for best performance/security.

Store the raw-value (plain text values) of your generated secrets somewhere in a safe place. We use a password-manager like KeyPassX. In order to fill the actual secret API objects, your secret values now need to get ``base64`` encoded. You can do this with:
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

You can now use the same procedure for all files within your ``core/secrets`` directory and finally deploy those API objects into your cluster issuing:
```
kubectl apply -f core/secrets
```