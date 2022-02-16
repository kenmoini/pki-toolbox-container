# pki-toolbox-container

A container with tools to work with x509 PKI

## Deployment to Kubernetes/OpenShift

You can easily deploy to K8s/OCP with a Pod:

```bash
## Log into OpenShift, if needed

## Create a new namespace/project
oc new-project pki-toolbox

## ...or switch to it
oc project pki-toolbox

## Deploy the pod
oc apply -f https://raw.githubusercontent.com/kenmoini/pki-toolbox-container/main/k8s-pod.yml

## Exec into the Pod
oc exec --stdin --tty pki-toolbox -- /bin/bash
```

## example-certs

There is a PKI chain that you can use for testing available in this repo:

```bash
## From within the running container...
cd /tmp

## Clone down this repo
git clone https://github.com/kenmoini/pki-toolbox-container
cd pki-toolbox-container

## Check the Root CA
openssl x509 -in example-certs/wildcard.kemo.labs.root-ca.pem -text -noout

## Check the chain
openssl verify -CAfile example-certs/wildcard.kemo.labs.root-ca.pem \
 -untrusted example-certs/wildcard.kemo.labs.ca-chain.pem example-certs/wildcard.kemo.labs.cert.pem
```
