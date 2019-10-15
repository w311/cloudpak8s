---
title: Installing On-Premises
weight: 400
---

- [Introduction](#introduction)
- [Prepare bastion node](#prepare-bastion-node)
- [Run the Integration Cloud Pak install](#run-the-integration-cloud-pak-install)
- [Deploy Capabilities](#deploy-capabilities)
- [Example files](#example-files)
  - [config.yaml](#configyaml)

## Introduction

This page describes all the steps on how to deploy the Integration Cloud Pak to a VMWARE onprem environment. The steps below includes instructions to:
1. Prepare the bastion node for installation
2. Run the Integration Cloud Pak installer to deploy to an existing OpenShift cluster


## Prepare bastion node

As the master nodes may not be accessed via ssh, we have to choose bastion node to proceed with the installation. 

Bastion node requirements:
- Sufficient disk space of `~120 GB`
- OpenShift CLI, which can be installed following the instruction [here on IBM Cloud](https://cloud.ibm.com/docs/openshift?topic=openshift-openshift-cli).
- docker installation
- kubectl

Once the CLIs are installed, check if you can login to openshift environment:

  1. Get login token from openshift console
  2. Run the `oc login` command from a terminal shell.
  3. You should see the cluster logged in message along with list of projects.


## Run the Integration Cloud Pak install

Integration Cloud Pak can’t install natively on openshift yet. Integration Cloud Pak provides a single installer that installs ICP as well loads all the helm charts for integration capabilities. One of the openshift worker nodes will be used as master node and proxy node. Another openshift worker node will be used as management node. This way we can install ICP on top of openshift without touching the managed openshift master nodes.

1. Download Integration Cloud Pak installer on the bastion node. See [Pre-requisites](../pre-reqs) for guidance.
2. Open a command line window on the boot node, and extract the contents of the Cloud Pak. It is a general recommendation to create a directory in /opt and extract into that directory:
``` md 
tar xf IBM_CLOUD_PAK_FOR_INTEGRATION_201.tar.gz --directory /opt/cp4i
```
4. Load the images onto your local docker registry:
``` md
tar xf ibm-cloud-private-rhos-3.2.0.1906.tar.gz -O | sudo docker load
```
5. Note down the IP addresses of OpenShift worker nodes. To get the IP addresses of the worker nodes, run:
``` md
oc get nodes
```
12. Navigate to your cluster directory `/opt/cp4i/installer/cluster`.
6. Edit the config.yaml with the information you have collected above. See the example at the end of the page for guidance.
7. Update kubeconfig file with your OpenShift cluster config
``` md
oc config view > kubeconfig
```

8. Update /etc/hosts with 127.0.0.1 docker-registry.default.svc
9. Open a terminal and run the port forward command
``` md
kubectl -n default port-forward svc/docker-registry 5000:5000
```
10. Log into docker
``` md
docker login -u $(oc whoami) -p $(oc whoami -t) docker-registry.default.svc:5000
```

13. Run the installer with:
  ``` 
  sudo docker run -t --net=host -e LICENSE=accept -v $(pwd):/installer/cluster:z -v /var/run:/var/run:z --security-opt label:disable ibmcom icp-inception-amd64:3.2.0.1907-rhel-ee install-with-openshift -vvv | tee install.log
  ```

## Deploy Capabilities

-  Integration
-  [API Management](../deploy-api-mgmt)
-  [Queue Manager](../deploy-queue-manager)
-  Kafka
-  Fast File Transfer
-  Secure Gateway

## Example files

This section contains examples of files you will be using throughout the installation. Refer to them for guidance on how to populate your own version of the files.


### config.yaml

``` md
# Licensed Materials - Property of IBM
# IBM Cloud private
# @ Copyright IBM Corp. 2019 All Rights Reserved
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

---
# A list of OpenShift nodes that used to run ICP components
cluster_nodes:
  master:
    - cp4i-ocp-a90beb40-worker-01
  proxy:
    - cp4i-ocp-a90beb40-worker-01
  management:
    - cp4i-ocp-a90beb40-worker-02

storage_class: glusterfs-storage

openshift:
  console:
    host: cp4i-res-master.rtp.raleigh.ibm.com
    port: 443
  router:
    cluster_host: icp-console.apps-cp4i-res.rtp.raleigh.ibm.com
    proxy_host: icp-proxy.apps-cp4i-res.rtp.raleigh.ibm.com

default_admin_password: admin
password_rules: ""

## You must have different ports if you deploy nginx ingress to OpenShift master node
# ingress_http_port: 80
# ingress_https_port: 443

kubernetes_cluster_type: openshift
## You can disable following services if they are not needed
## Disabling services may impact the installation of IBM CloudPaks.
## Proceed with caution and refer to the Knowledge Center document for specific considerations.
# auth-idp
# auth-pap
# auth-pdp
# catalog-ui
# helm-api
# helm-repo
# icp-management-ingress
# metering
# metrics-server
# mgmt-repo
# monitoring
# nginx-ingress
# platform-api
# platform-ui
# secret-watcher
# security-onboarding
# web-terminal

management_services:
  monitoring: enabled
  metering: enabled
  logging: enabled
  custom-metrics-adapter: disabled
  platform-pod-security: enabled



archive_addons:
  icp4i:
    namespace: integration
    repo: local-charts
    path: icp4icontent/IBM-Cloud-Pak-for-Integration-2.0.0.tgz
    scc: ibm-anyuid-scc

    charts:
    - name: ibm-icp4i-prod
      pullSecretValue: image.pullSecret
      values:
        image:
          pullSecret: sa-integration
        tls:
          hostname: icp-proxy.apps-cp4i-res.rtp.raleigh.ibm.com #hostname of the ingress proxy to be configured
          generate: true

  mq:
    namespace: mq
    repo: local-charts
    path: icp4icontent/IBM-MQ-Advanced-for-IBM-Cloud-Pak-for-Integration-3.0.0.tgz
    scc: ibm-anyuid-scc

  ace:
    namespace: ace
    repo: local-charts
    path: icp4icontent/IBM-App-Connect-Enterprise-for-IBM-Cloud-Pak-for-Integration-2.0.0.tgz
    scc: ibm-anyuid-scc

  eventstreams:
    namespace: eventstreams
    repo: local-charts
    path: icp4icontent/IBM-Event-Streams-for-IBM-Cloud-Pak-for-Integration-1.3.1-for-OpenShift.tgz
    scc: ibm-restricted-scc

  apic:
    namespace: apic
    repo: local-charts
    path: icp4icontent/IBM-API-Connect-Enterprise-for-IBM-Cloud-Pak-for-Integration-1.0.1.tgz
    scc: ibm-anyuid-hostpath-scc

  aspera:
    namespace: aspera
    repo: local-charts
    path: icp4icontent/IBM-Aspera-High-Speed-Transfer-Server-for-IBM-Cloud-Pak-for-Integration-1.2.1.tgz
    scc: ibm-anyuid-hostaccess-scc

  datapower:
    namespace: datapower
    repo: local-charts
    path: icp4icontent/IBM-DataPower-Virtual-Edition-for-IBM-Cloud-Pak-for-Integration-1.0.3.tgz
    scc: ibm-anyuid-scc

  assetrepo:
    namespace: integration
    repo: local-charts
    path: icp4icontent/IBM-Cloud-Pak-for-Integration-Asset-Repository-2.0.0.tgz
    scc: ibm-anyuid-scc


```
