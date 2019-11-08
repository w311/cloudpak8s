---
title: Install on Red Hat OpenShift on IBM Cloud
weight: 300
---

## Introduction

This page describes all the steps on how to deploy the Integration Cloud Pak to managed openshift on IBM cloud. The steps below includes instructions to:
- [Introduction](#introduction)
- [Deploy a managed OpenShift Cluster on IBM Cloud](#deploy-a-managed-openshift-cluster-on-ibm-cloud)
- [Prepare a boot node](#prepare-a-boot-node)
- [Install ICP on Red Hat OpenShift](#install-icp-on-red-hat-openshift)
- [Deploy Capabilities](#deploy-capabilities)
- [Example files](#example-files)
  - [host](#host)
  - [config.yaml](#configyaml)


## Deploy a managed OpenShift Cluster on IBM Cloud

The capability to add a managed OpenShift cluster in IBM Cloud is available. The architecture of this service is:

![ROKS Architecture]({{ site.github.url }}/assets/img/integration/roks-architecture.png)

More information is available at [IBM Cloud](https://cloud.ibm.com/docs/containers?topic=containers-openshift_tutorial).

To deploy the managed openshift cluster on IBM Cloud, ensure that you have the following IBM Cloud IAM access policies:
- The **Administrator** __platform role__ for IBM Cloud Kubernetes Service
- The **Writer** or **Manager** __service role__ for IBM Cloud Kubernetes Service
- The **Administrator** __platform role__ for IBM Cloud Container Registry

Make sure that the __API key__ for the IBM Cloud region and resource group is set up with the correct infrastructure permissions, **Super User**, or the __minimum roles__ to create a cluster.

Once your account has the above IAM policies:
1. Log in to your IBM Account
2. Select **Kubernetes** from the hamburger menu and click **Create Cluster**
3. For **Select a plan**, choose **Standard**
4. For the Cluster type and version, choose `OpenShift`. Red Hat OpenShift on IBM Cloud supports OpenShift version `3.11` only, which includes Kubernetes version `1.11`. The operating system is `Red Hat Enterprise Linux 7`.
5. Fill out your cluster name, resource group, and tags
6. For the Location, set the geography to North America or Europe, select Single one availability zone, and then select Washington, DC or London worker zones.
7. For Default worker pool, choose an available flavor for your worker nodes. We recommend at least 16 cores and 32 GB RAM.
8. Set a number of worker nodes to create per zone. We recommend 9.
9. Click **Create Cluster**

The cluster will now be created. This process should take around 15 minutes, but depends on your configuration. Once the cluster creation completes:
1. From the cluster details page, click **OpenShift web console**.
2. From the dropdown menu in the OpenShift container platform menu bar, click **Application Console**. The Application Console lists all project namespaces in your cluster. You can navigate to a namespace to view your applications, builds, and other Kubernetes resources.
3. From the OpenShift web console menu bar, click your profile **IAM#user.name@email.com**  and then click **Copy Login Command**. Paste the copied oc login command into your terminal to authenticate via the CLI.

## Prepare a boot node

As the master nodes are managed by IBM Cloud and cannot be accessed via ssh, we have to choose a boot node to proceed further with the installation. The boot node can be a linux VM or your laptop. **The installation assume you are using your laptop as the boot node.**

Boot node requirements:
- Sufficient disk space of `~120 GB`
- IBM Cloud CLI, which can be installed using `curl -sL https://ibm.biz/idt-installer | bash`
- OpenShift CLI, which can be installed following the instruction [here on IBM Cloud](https://cloud.ibm.com/docs/openshift?topic=openshift-openshift-cli).

Once the CLIs are installed, check if you can access your account using the CLI:

- **For the IBM Cloud CLI:**
  1. Run `ibmcloud login --sso`
  2. Get the onetime code to login and then select the appropriate account you have deployed the openshift cluster to.  [![IBM Cloud login]({{ site.github.url }}/assets/img/integration/ibmcloud-login-sso.png)]({{ site.github.url }}/assets/img/integration/ibmcloud-login-sso.png)
  3. Run `ibmcloud ks clusters`. You should see the name of the cluster you created in the list.  [![ibmcloud ks clusters]({{ site.github.url }}/assets/img/integration/ibmcloud-ks-clusters.png)]({{ site.github.url }}/assets/img/integration/ibmcloud-ks-clusters.png)
  4. Get the OpenShift cluster details `ibmcloud ks cluster get --cluster <clustername> --showResources`  [![ocp cluster details]({{ site.github.url }}/assets/img/integration/ocp-cluster-details.png)]({{ site.github.url }}/assets/img/integration/ocp-cluster-details.png)

- <a name="oc-login-process">**For the OpenShift CLI:**</a>
  1. Click your profile **IAM#user.name@email.com** and then **Copy Login Command**.  [![OCP Web Console]({{ site.github.url }}/assets/img/integration/ocp-web-console.png)]({{ site.github.url }}/assets/img/integration/ocp-web-console.png)
  2. Paste the copied oc login command into your terminal to authenticate via the CLI.

- **Get additional cluster info for installation**
     
  1. Note down the ipaddress of the worker nodes. To get the ipaddress of the worker nodes, run the command `oc get nodes`  [![Get Nodes]({{ site.github.url }}/assets/img/integration/oc-get-nodes.png)]({{ site.github.url }}/assets/img/integration/oc-get-nodes.png))
  2. Get the storage class. Run the command `oc get sc` and choose a file storage. _**ibmc-file-gold is recommended**_  [![Get Storage Classes]({{ site.github.url }}/assets/img/integration/oc-get-sc.png)]({{ site.github.url }}/assets/img/integration/oc-get-sc.png))

## Install ICP on Red Hat OpenShift

As the Cloud Pak for Integration can’t install natively on OpenShift yet, ICP on RHOS needs to be installed as part of the cloudpak installation. Download the ICP on RHOS Docker package, [**IBM_CLOUD_PAK_FOR_INTEGRATION.tar.gz** from XL Downloads or Passport Advantage.](https://w3-03.ibm.com/software/xl/download/ticket.wss) 


One of the OpenShift worker nodes will be used as master node and proxy node. Another OpenShift worker node will be used as management node. This way we can install ICP on top of OpenShift without touching the managed OpenShift master nodes.

1. Download Cloud Pak for Integration installer on the boot node. See [Pre-requisites](https://pages.github.ibm.com/CASE/cloudpak-onboard-residency/integration/pre-reqs/) for guidance.
2. Open a command line window on the boot node, and extract the contents of the Cloud Pak:
``` md 
tar xf IBM_CLOUD_PAK_FOR_INTEGRATION_201.tar.gz
```
3. The extracted directory is `installer_files/cluster`. The `tar` above comes with ICP version `1906`.
4. Now you need to load the ICP images onto your local docker registry. Go to `installer_files/cluster/images`. Run:
``` md
tar xf ibm-cloud-private-rhos-3.2.0.1906.tar.gz -O | sudo docker load
```
5. Note down the IP addresses of OpenShift worker nodes. To get the IP addresses of the worker nodes, run:
``` md
oc get nodes
```
6. Get the OpenShift cluster name by running:
``` md
ibmcloud ks clusters
```
7. Get the cluster details by running:
``` md
ibmcloud ks cluster-get --cluster `<clustername>` --showResources
```
8. Get the storage class. `ibmc-file-gold` is recommended. To get the storage classes run:
``` md
oc get sc
```
9. Get the unique domain name. To do this run the command:
``` md
oc -n default get routes  
```  

    [![Get Routes]({{ site.github.url }}/assets/img/integration/oc-get-routes.png)]({{ site.github.url }}/assets/img/integration/oc-get-routes.png))
10. Edit the [config.yaml](#configyaml) with the information you have collected above. See the example at the end of the page for guidance.
11. Update /etc/hosts with **`127.0.0.1 docker-registry.default.svc`**
12. Navigate to your cluster directory `installer_files/cluster`.
13. Make sure you're still logged in. If not follow the instructions above at [Access Openshift CLI](#oc-login-process).
14. Before running the installer command you must load the docker registry with IBM Cloud Private. Navigate to <installation_files_path>/installer_files/cluster/images. Load the ICP image:  
    ``` md
    tar xf ibm-cloud-private-rhos-3.2.0.tar.gz -O | sudo docker load
    ```
		
    >**This may take more than 30 minutes so be patient**  
    >NOTE: ACTUAL command should be:  
`tar xf ibm-cloud-private-rhos-3.2.0.1906.tar.gz -O | sudo docker load`

15. Open another command window and run the command  
    `kubectl -n default port-forward svc/docker-registry 5000:5000`  
    This exposes port 5000 on the boot node (wherever this is run). You need to leave the window open or else the port-forwarding will stop.
16. Return to your original command window and make sure you are still logged into via the oc login command copied from the OpenShift web console.
17. Log into docker  
    `docker login -u $(oc whoami) -p $(oc whoami -t) docker-registry.default.svc:5000`

18. Change directory to the cluster directory of where you downloaded and extracted the Cloud Pak tar.gz file   
    `cd <download directory>/installer_files/cluster`

19. In the cluster directory, run this command:  
    `oc config view > kubeconfig`

20. Run the installer with:  
  ```
  sudo docker run -t --net=host -e LICENSE=accept -v $(pwd):/installer/cluster:z -v /var/run:/var/run:z --security-opt label:disable ibmcom/icp-inception-amd64:3.2.0.1907-rhel-ee install-with-openshift -vvv| tee install.log  
  ```  
  The installer will configure namespaces, routes, and security context constraints needed for the Cloud Pak components. For the integration Cloud Pak the installer will also install and configure the integration Cloud Pak Navigator will be installed and configured. **This may take a long time to complete.**

## Deploy Capabilities

-  Integration
-  [API Management](../deploy-api-mgmt)
-  [Queue Manager](../deploy-queue-manager)
-  Kafka
-  Fast File Transfer
-  Secure Gateway

## Example files

This section contains examples of files you will be using throughout the installation. Refer to them for guidance on how to populate your own version of the files.

### host

``` md
[master]
10.148.87.182

[worker]
10.148.87.152
10.148.87.159
10.148.87.143
10.148.87.161
10.148.87.158
10.148.87.155
10.148.87.166

[proxy]
10.148.87.182

[management]
10.148.87.162
```

### config.yaml

``` yaml
# Licensed Materials - Property of IBM
# IBM Cloud private
# @ Copyright IBM Corp. 2019 All Rights Reserved
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

---

# A list of OpenShift nodes that used to run ICP components
cluster_nodes:
  master:
    - 10.188.55.70 <IP of one of the RHOS worker nodes>
  proxy:
    - 10.188.55.70 <IP of one of the RHOS worker nodes>
  management:
    - 10.188.55.71 <IP of one of the worker nodes>

storage_class: ibmc-file-gold <choose storage class available to IBM >

openshift:
  console:
    host: c100-e.us-east.containers.cloud.ibm.com
    port: 32227
  router:
    cluster_host: icp-console.jbh-icp4i-06984b2d85682a68a3a5ac25e90299e6-0001.us-east.containers.appdomain.cloud
    proxy_host: icp-proxy.jbh-icp4i-06984b2d85682a68a3a5ac25e90299e6-0001.us-east.containers.appdomain.cloud 

    # default_admin_user: admin    
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
          hostname: icp-proxy.jbh-icp4i-06984b2d85682a68a3a5ac25e90299e6-0001.us-east.containers.appdomain.cloud < hostname of the ingress proxy to be configured>
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
