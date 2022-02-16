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
oc apply -f https://raw.githubusercontent.com/kenmoini/pki-toolbox-container/main/openshift/k8s-pod.yml

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

## List system trusted roots
cat /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem | grep '^\#'

## Download a public trusted Server Certificate
echo -n | openssl s_client -connect kenmoini.com:443 -servername 'kenmoini.com' | openssl x509 > kenmoini.com.pem

## Download the Let's Encrypt R3 Intermediate Certificate
wget https://letsencrypt.org/certs/lets-encrypt-r3.pem

## Verify the Intermediate against the system root store
openssl verify lets-encrypt-r3.pem

## Combine Intermediate and Server Certificate
cat lets-encrypt-r3.pem kenmoini.com.pem > kenmoini-bundle.pem

## Verify the chain
openssl verify kenmoini-bundle.pem
```

## PKI in OpenShift

Things to know about OpenShift when deploying custom Root CAs:

- You can apply a ***cluster-wide*** Root CA via a ConfigMap named `user-ca-bundle` in the `openshift-config` Project.  An example is located at `./openshift/configmap-proxy-root-ca.yml` and `./openshift/configmap-proxy-full-chain.yml`
  
  This information is sourced from: https://docs.openshift.com/container-platform/4.9/networking/configuring-a-custom-pki.html#nw-proxy-configure-object_configuring-a-custom-pki
  
  Once the ConfigMap is applied there are a number of Operators that will cycle as it is applied to all nodes in the cluster, be that control plane, infrastructure, or application nodes.

- You can apply ***node-type specific*** Root CAs via MachineConfigs.  An example is located at `./openshift/machineconfig-root-ca.yml` and `./openshift/machineconfig-full-chain.yml`

- These two options will apply the CA bundles to the nodes, then run the update-ca-trust command to generate the system root anchors.  This can be seen when using the Node Terminals and doing a `chroot /host` then `cat /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem | grep '^\#'`

- With the cluster-wide deployment of custom CA Roots via the `user-ca-bundle` ConfigMap, you can then edit the cluster Proxy and define that ConfigMap as the `.spec.trustedCA` - apply that via `oc edit proxy/cluster`
  
  Once this is applied to the Proxy cluster configuration, you can then inject the bundle via a labeled ConfigMap into different Namespaces - an example is located at `./openshift/configmap-namespaced-injection.yml`.  Once that ConfigMap is applied to a Namespace, OpenShift will update the `.data` contents with the baked Root CA Bundle that was applied via the cluster-wide `user-ca-bundle` ConfigMap.  The namespaced ConfigMap can then be attached to Pods, an example is located at `./openshift-k8s-pod.yml`

- Most containers will have the `ca-certificates` package installed, which means the container image has its own set of root CA anchors.  You can mount the host's root CA anchors, such as the ones applied by the ConfigMaps or MachineConfigs, but you will need to provide additional filesystem and RBAC/SCC permissions to each container that wants to mount that hostPath.

- The easiest way to provide all your application workloads custom Root CAs with the fewest modifications to YAML objects would be to do so at build time.
