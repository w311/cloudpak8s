---
title: Prerequisites
weight: 200
---
- 
# make sure there is a space after the - so that the TOC is generated
{:toc}

## Install

### NFS
The persistent volumes used by the different Cloud Pak for Automation components in the following chapters are relying on NFS. Before starting the install of any component, it is thus required to set-up an NFS server. An example for how to set-up and verify an NFS server for Redhat 7 can be found [here](https://linuxconfig.org/quick-nfs-server-configuration-on-redhat-7-linux).

### Helm

The following instructions are extracted from [here](https://blog.openshift.com/getting-started-helm-openshift/).

- Download `helm` binaries and install the client only:
```
wget https://get.helm.sh/helm-v2.12.2-linux-386.tar.gz
tar -zxvf helm-v2.12.2-linux-386.tar.gz
mv linux-386/helm /usr/local/bin/
helm init --client-only
helm version
```

- Create an openshift project where the Helm `tiller` (the server side) will be installed:
```
oc new-project tiller
oc project tiller
export TILLER_NAMESPACE=tiller
```
You can add the `export TILLER_NAMESPACE=tiller` to your `~/.bash_profile` for instance to avoid exporting in each session.

- Install the `tiller`:

Use the same version of the client in the following command line to have the same version of client and tiller.
```
oc process -f https://github.com/openshift/origin/raw/master/examples/helm/tiller-template.yaml -p TILLER_NAMESPACE="${TILLER_NAMESPACE}" -p HELM_VERSION=v2.12.2 | oc create -f -
oc get pods
# Check pods are running
oc rollout status deployment tiller
helm init
helm version
```

## Prepare

### Logging-in to your cluster

#### IBM Cloud OpenShift cluster
Start by loging in to IBM Cloud with the `ibmcloud login` or `ibmcloud login --sso` command, then select your cluster and login to it.
```
ibmcloud oc cluster-config --cluster <your-cluster-name>
oc login 
```

#### On-prem OpenShift cluster
Login directly to your cluster:
```
oc login -u admin -p admin https://<your-cluster-url>/
```

### Accessing the Docker registry

#### IBM Cloud OpenShift cluster
To expose the `docker-registry.default.svc`, open a command window, login to OpenShift and run the following command:
```
kubectl -n default port-forward svc/docker-registry 5000:5000 &
```
This is exposing port 5000 on the boot node (wherever this is run). You need to leave the command window open or else the port-forwarding will stop. Be aware of the potential timeout of port forwarding during the images push.

#### On-prem OpenShift cluster
To prepare Docker access, edit the `/etc/docker/daemon.json` Docker daemon configuration file to include the `"insecure-registries"` property, as shown on the example below:
``` 
{
  "insecure-registries" : ["docker-registry-default.apps-cp4a-res.rtp.raleigh.ibm.com"]
}
```
Restart docker daemon:
```
systemctl restart docker
```

