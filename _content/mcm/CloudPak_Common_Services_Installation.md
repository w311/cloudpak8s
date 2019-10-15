## Common Services installation for MCM

This describes the steps to install Common Services supporting all Cloud Paks, in this example particularly MCM.

{% include_relative cp4mcm_common_services_example.md %}

## Quickstart installation

For the following steps, ensure the OpenShift Client, the Docker client are installed.

1. Download the Common Services 'ICP on RHOS' docker package `ibm-cloud-private-rhos-3.2.1.tar.gz` from XL Downloads or Passport Advantage

2. Login to the OCP Cluster.
```
oc login --token=<your_token> --server=https://c100-e.us-east.containers.cloud.ibm.com:32653
```
3. Load the container images into the local docker registry.
```
tar xf ibm-cloud-private-rhos-3.2.1.tar.gz -O | sudo docker load
```
4. Create a working directory as the root user.
```
mkdir /opt/mcm; cd /opt/mcm
```
5. Extract the installer configuration files becuase they need to be modified.
```
sudo docker run --rm -v $(pwd):/data:z -e LICENSE=accept --security-opt label:disable ibmcom/icp-inception-amd64:3.2.1-rhel-ee cp -r cluster /data
```
6. Get the OCP worker node names. The node names are used to identify the `master`, `proxy` and `management` nodes.
```
oc get nodes
```
7. Create the kubeconfig file in the . 
```
export KUBECONFIG=/opt/mcm/cluster/kubeconfig
oc login --token=<your_token> --server=https://c100-e.us-east.containers.cloud.ibm.com:32653
```
8. Edit the config.yaml file and update the  `master`, `proxy` and `management` nodes with the OCP worker node names previously identified.

```
 cluster_nodes:
   master:
     - 10.148.87.135
   proxy:
     - 10.148.87.135
   management:
     - 10.148.87.186
```
9. Identify a dynamic storage class in the list returned from the following command.
```
oc get sc
```
10. Update the config.yaml file with the identified storage_class name.
```
storage_class: ibmc-block-bronze
```
11. Update the password and rules in config.yaml.
```
default_admin_password: admin
password_rules:
 - '(.*)'
```
12. Get the unique domain name of the OCP cluster. The following command shows the current routes with the domain names. You will use the domain name to update the config.yaml.
```
oc -n default get routes|awk '{print $2}'
```
13. Update the config.yaml with the `openshift.console.host` `openshift.console.port` provided. Update the `openshift.router.proxy_host` and `openshift.router.cluster_host` with the domain name.
```
openshift:
    console:
        host: c100-e-us-east-containers-cloud-ibm-com
        port: 32653
    router:
        cluster_host: icp-console.mcmresidency1-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud
        proxy_host: icp-proxy.mcmresidency1-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud
```
14. Define the management_services in `config.yaml` appropriate to your Cloud Pak. Refer to the management services enablement defaults listed later in this document.

15. Install the Cloud Pak Common Services.
```
docker run -t --net=host -e LICENSE=accept -v $(pwd):/installer/cluster:z -v /var/run:/var/run:z -v /etc/docker:/etc/docker:z --security-opt label:disable ibmcom/icp-inception-amd64:3.2.1-rhel-ee install-with-openshift
```
16. Connect to the MCM hub console using the `icp-console` information from the `config.yaml`

## Descriptive Installation

Get the token from the completed OCP cluster deployment.

Login to OCP.
```
oc login --token=<your_token> --server=https://c100-e.us-east.containers.cloud.ibm.com:32653
```

### Establish a valid route to the OCP registry

Get the existing route information.
```
oc get routes

NAME               HOST/PORT                                                                                                         PATH      SERVICES           PORT               TERMINATION   WILDCARD
docker-registry    docker-registry-default.mcmresidency1-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud              docker-registry    <all>              passthrough   None
registry-console   registry-console-default.mcmresidency1-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud             registry-console   registry-console   passthrough   None
```
Delete the invalid route to the Registry.
```
oc delete route docker-registry

route.route.openshift.io "docker-registry" deleted
```
Create a new route to the Registry.
```
oc create route --service=docker-registry --hostname=docker-registry.mcmresidency1-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud reencrypt

route.route.openshift.io/docker-registry created
```

Use the following installation instructions:
[MCM Operator based installation](https://github.ibm.com/IBMPrivateCloud/roadmap/blob/master/feature-specs/installer/ibmservice-operator.md)

### Sample command using API and token

Check that the token allows you to work with the API.

`curl -H "Authorization: Bearer <your_token>" "https://c100-e.us-east.containers.cloud.ibm.com:32653/oapi/v1/users/~"`

### Resizing the OCP Image Registry on IBMCloud

Get the details of the existing Registry PVC.

```
oc get pvc

NAME               STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS       AGE
registry-backing   Bound     pvc-f76d181b-cf3b-11e9-ad8e-62183e235b01   20Gi       RWX            ibmc-file-bronze   21h
root@virtualserver01:~/downloads# oc describe pvc registry-backing
Name:          registry-backing
Namespace:     default
StorageClass:  ibmc-file-bronze
Status:        Bound
Volume:        pvc-f76d181b-cf3b-11e9-ad8e-62183e235b01
Labels:        billingType=hourly
              region=us-east
              zone=wdc04
Annotations:   ibm.io/provisioning-status=complete
              kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"v1","kind":"PersistentVolumeClaim","metadata":{"annotations":{},"labels":{"billingType":"hourly"},"name":"registry-backing","namespace":...
              pv.kubernetes.io/bind-completed=yes
              pv.kubernetes.io/bound-by-controller=yes
              volume.beta.kubernetes.io/storage-provisioner=ibm.io/ibmc-file
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      20Gi
Access Modes:  RWX
Events:        <none>
```
This example is 20GB which is not enough. Save details of the Region and the Avaiability Zone.

Create a 100GB PVC definition using the information from the existing PVC above. Following is a sample `pvc.yaml`, choose a storage class to suit your needs.
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  annotations:
    pv.kubernetes.io/bound-by-controller: "yes"
    volume.beta.kubernetes.io/storage-provisioner: ibm.io/ibmc-file
  creationTimestamp: null
  finalizers:
  - kubernetes.io/pvc-protection
  labels:
    billingType: hourly
    region: us-east
    zone: wdc04
  name: registry-backing1
  selfLink: /api/v1/namespaces/default/persistentvolumeclaims/registry-backing
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 100Gi
  storageClassName: ibmc-file-gold
```  
Next create the PVC.
```
oc create -f pvc.yaml
```
Ensure the PVC is created by running `oc get pvc`.

```
oc get pvc

NAME                STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS       AGE
registry-backing    Bound     pvc-f76d181b-cf3b-11e9-ad8e-62183e235b01   20Gi       RWX            ibmc-file-bronze   21h
registry-backing1   Bound     pvc-99d6a9e0-cfed-11e9-9241-924d8990d738   100Gi      RWX            ibmc-file-gold     2m
```

After the PVC is created, update the docker-registry to use the new volume.
```
oc set volume deployment/docker-registry --add --name=registry-storage -t pvc --claim-name=registry-backing1 --overwrite

deployment.extensions/docker-registry volume updated

```
An example of registry-backing1 for PVC is used in the previous command.
Ensure the pods are running.
```

oc get pods
NAME                                READY     STATUS    RESTARTS   AGE
docker-registry-7c97448b48-8wzhp    1/1       Running   0          1m
docker-registry-7c97448b48-tvftl    1/1       Running   0          1m
registry-console-6b95fbbf59-jgkm8   1/1       Running   0          21h
router-77777bb7f8-7wmts             1/1       Running   0          21h
router-77777bb7f8-dv8zb             1/1       Running   0          21h
```
Confirm that the new pod is associated with the new PVC.
```
oc describe pod docker-registry-7c97448b48-8wzhp|egrep -i "claimname|state"
   State:          Running
   ClaimName:  registry-backing1
```

Remove the old registry PVC.

```
oc delete pvc\registry-backing
```

### Installing Common Services

As the MCM Cloud Pak can not install natively on OpenShift, Common Services must be installed before other Cloud Pak components. Download the 'ICP on RHOS' docker package `ibm-cloud-private-rhos-3.2.1.tar.gz` from XL Downloads or Passport Advantage.

This file is about 35GB in size.

You will tag three OpenShift Worker nodes as `Master`, `Proxy` and `Management`. You can install the Common Services on the OpenShift Worker nodes without touching the managed OpenShift master nodes.

You will need a VM or workstation with a connection to your OCP cluster. This machine is your 'Boot' node.

Download, uncompress and install the OCP CLI tools `openshift-client-mac-4.1.11.tar.gz` from
[OCP Client binaries](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/)

Next update $KUBECONFIG to point to a file that will hold the profile information generated by the upcoming `oc login` command

The default location for the kubernetes config file is `~/.kube/config` unless you override it with the following.

From your Boot node terminal ...

`export KUBECONFIG=$(pwd)/myclusterconfig`

`oc login --token=EtZqGLpwxpL8b6CAjs9Bvx6kxe925a1HlB__AR3gIOs --server=https://c100-e.us-east.containers.cloud.ibm.com:32653
`
You can see that `$(pwd)/myclusterconfig` has been populated.

You need to load the container images into the local registry.

`tar xf ibm-cloud-private-rhos-3.2.1.tar.gz -O | sudo docker load`

Create an installation directory on the boot node.

`mkdir /opt/cs; cd /opt/cs`

Extract the cluster directory
`sudo docker run --rm -v $(pwd):/data:z -e LICENSE=accept --security-opt label:disable ibmcom/icp-inception-amd64:3.2.1-rhel-ee cp -r cluster /data`

Copy the kubeconfig file.

`cp $KUBECONFIG /opt/cs/cluster/kubeconfig`

## Common Services installation config.yaml

Next update the `config.yaml` file before starting the MCM and Common Services installation.

**Note** that you will only see the OCP worker nodes in an IKS managed cluster. Also the node names are the sames as the private IP address of their hosting VMs.

Next you need to collect some information for the `config.yaml` file.

Run `oc get nodes` to get all the cluster node names. Use these OCP worker node names to select Master, Proxy and Management targets. Assign any of the OCP Worker nodes to each of the `cluster_nodes`.

Update the `cluster_nodes` section of the `config.yaml` to identify your chosen OCP worker nodes.

```
oc get nodes
NAME            STATUS    ROLES                                AGE       VERSION
10.148.87.135   Ready     compute,infra                        6h        v1.11.0+d4cacc0
10.148.87.140   Ready     compute,infra                        6h        v1.11.0+d4cacc0
10.148.87.186   Ready     compute,infra                        6h        v1.11.0+d4cacc0
```

Use the node information to create the following entries in the `config.yaml`

```
# A list of OpenShift nodes that used to run ICP components
cluster_nodes:
  master:
    - 10.148.87.135
  proxy:
    - 10.148.87.135
  management:
    - 10.148.87.186
```

You need some persistent storage for some common service pods, so use `oc get storageclass` to identify an OCP dynamic block storage class.

```
oc get sc
NAME                          PROVISIONER         AGE
default                       ibm.io/ibmc-file    4h
ibmc-block-bronze (default)   ibm.io/ibmc-block   4h
ibmc-block-custom             ibm.io/ibmc-block   4h
ibmc-block-gold               ibm.io/ibmc-block   4h
ibmc-block-retain-bronze      ibm.io/ibmc-block   4h
ibmc-block-retain-custom      ibm.io/ibmc-block   4h
ibmc-block-retain-gold        ibm.io/ibmc-block   4h
ibmc-block-retain-silver      ibm.io/ibmc-block   4h
ibmc-block-silver             ibm.io/ibmc-block   4h
ibmc-file-bronze              ibm.io/ibmc-file    4h
ibmc-file-custom              ibm.io/ibmc-file    4h
ibmc-file-gold                ibm.io/ibmc-file    4h
ibmc-file-retain-bronze       ibm.io/ibmc-file    4h
ibmc-file-retain-custom       ibm.io/ibmc-file    4h
ibmc-file-retain-gold         ibm.io/ibmc-file    4h
ibmc-file-retain-silver       ibm.io/ibmc-file    4h
ibmc-file-silver              ibm.io/ibmc-file    4h
```

Use the default block class `ibmc-block-bronze`
Next add `storage_class: ibmc-block-bronze` to the `config.yaml`

Get the unique domain name of the OCP cluster.

```
oc -n default get routes|awk '{print $2}'
HOST/PORT
registry-console-default.mcmresidency1-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud
```

Update the default password for the `admin` user. Remember that this becomes the MCM login password for the `admin` user. This is not an OCP account.

```
default_admin_password: admin
password_rules:
- '(.*)'
```

Update the `openshift.console.host` and `openshift.console.port` values. This is Kubernetes API server information. You can get them from the $KUBECONFIG file - `clusters.cluster.server` value.

Update `openshift.router.proxy_host` and `openshift.router.cluster_host` with the domain values from the command.

`oc get route console -n openshift-console -o jsonpath='{.spec.host}'| cut -f 2- -d "."`

Next use `icp-console.<router domain>` as the value for `openshift.router.cluster_host` and `icp-proxy.<router domain>` as the value for `openshift.router.proxy_host`.

Following is a completed example:

```
openshift:
    console:
        host: c100-e-us-east-containers-cloud-ibm-com
        port: 32653
    router:
        cluster_host: icp-console.mcmresidency1-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud
        proxy_host: icp-proxy.mcmresidency1-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud

```

Next install the Common services.

```
docker run -t --net=host -e LICENSE=accept -v $(pwd):/installer/cluster:z -v /var/run:/var/run:z -v /etc/docker:/etc/docker:z --security-opt label:disable ibmcom/icp-inception-amd64:3.2.1-rhel-ee install-with-openshift
```
When the install finishes, then connect to the MCM hub console using the `icp-console` information from the `config.yaml`

```
config.yaml extract
cluster_host: icp-console.mcmresidency1-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud

web browser URL
https://icp-console.mcmresidency1-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud

```
Your `admin` password is configured in the `config.yaml` file with the `default_admin_password` value.

### Common Services Disabled by default
```
calico-route-reflector
platform-security-netpols
platform-pod-security
storage-glusterfs
storage-minio
istio
custom-metrics-adapter
vulnerability-advisor
node-problem-detector-draino
multicluster-endpoint
system-healthcheck-service
```
### Common Services Enabled by default
```
calico/nsx-t
kmsplugin
tiller
image-manager
kube-dns
cert-manager
monitoring-crd
nvidia-device-plugin
mongodb
metrics-server
nginx-ingress
service-catalog
platform-api
auth-idp
auth-apikeys
auth-pap
auth-pdp
icp-management-ingress
platform-ui
catalog-ui
security-onboarding
secret-watcher
oidcclient-watcher
metering
monitoring
helm-repo
mgmt-repo
helm-api
logging
image-security-enforcement
web-terminal
audit-logging
key-management
multicluster-hub
```
