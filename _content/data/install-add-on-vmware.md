---
title: Install Add-Ons on Vmware OCP environment
weight: 800
---


## Set Up the OpenShift Client CLI Tools and Access the Cluster

1. If you haven't done so already, install the OpenShift client CLI tools using the directions at [here](https://cloud.ibm.com/docs/openshift?topic=openshift-openshift-cli).
2. Login to the OpenShift console.  In the upper right hand side of the page, click on your user name and select "Copy Login Command".

![LoginScreen](https://pages.github.ibm.com/CASE/cloudpak-onboard-residency/assets/img/cp4d/qijunlogin.jpg)

3. Paste the command in a shell and a response will be returned with a list of projects and the current project selected.

## Set Up the CP4D "deploy.sh" for Add-On Installation

1. Retrieve the CP4D installer and only extract its contents using the "--extract-only" switch.  For example,
_"./installer.x86_64.520 --extract-only"_
2. The "deploy.sh" script that will be used later to install an add-on will be located at "/ibm/InstallPackage/components/".

## Install helm and tiller

1. Download helm tool

       $ curl -s https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz | tar xz

2. Copy the helm too to /bin directory

       $ cp -f ./linux-amd64/helm /usr/local/bin/ /usr/bin/

3. Check “helm” version

       $ helm version

4. Configure “helm” with OpenShift server


       $ oc whoami - find the logged in user (1)
       $ oc whoami –t - To find password (2)
       $ oc get routes –n default àFind the docker registry url (3)
       $ docker login –u openshift –u <password> https://<url from the command 3>

5. List the deployed helm charts in the server

       $oc get pods –all-namespacs | grep tiller
       $ export TILLER_NAMESPACE=<namespace> --> Namespace of the tiller running in Server $ helm list

## Get the Add-On to be Installed

For this example, the "Watson Machine Learning" add-on tar will be used.  Download the add-on code and place it somewhere like "/ibm/modules"

## Install the Add-On

_"./deploy.sh -o -d /ibm/modules/watson_machine_learning.tar"_

## Lesson Learn

Running "helm list" failed after "helm version" succeeded.

```
[root@res-cdoan-29918d73-master-01 ~]# helm list
Error: Get http://localhost:8080/api/v1/namespaces/zen/configmaps?labelSelector=OWNER%!D(MISSING)TILLER: dial tcp 127.0.0.1:8080: connect: connection refused
[root@res-cdoan-29918d73-master-01 ~]#
```

 Solution:
   
 Step#1:

```
  oc --namespace=zen create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=zen:default
  clusterrolebinding.rbac.authorization.k8s.io/add-on-cluster-admin created
```
 Step#2:

```
  oc -n zen edit deployment  tiller-deploy
```

{% include figure.html src="/assets/img/cp4d/tiller-deploy-edit.png" alt="Edit Tiller Deploy" caption="Edit Tiller Deploy" %}


