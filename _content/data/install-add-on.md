---
title: Install Add-Ons on Red Hat OpenShift on IBM Cloud
weight: 700
---

## **Overview**
**Note:** Add-ons for Cloud Pak for Data in the Red Hat OpenShift on IBM Cloud is **NOT** officially supported at this time.  Some add-ons, like data virtualization, may install successfully, but will have an issue during provisioning.  There are technical issues with this and other add-ons, like Db2 Warehouse, where "SELinux" can not be in "enforcing" mode.  However, Red Hat OpenShift itself requires "SELinux" to be in "enforcing" mode.  Since this is a managed environment, access to change this setting is not available. 
There are plans for add-ons to support this environment in the future.  The following describes a way to install the "Watson Machine Learning" add-on which appears to work successfully.  But it should be noted again that this is **NOT** officially supported.

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
1. Use the following script to set up helm and tiller
[ helm_install.sh](https://pages.github.ibm.com/CASE/cloudpak-onboard-residency/assets/img/helm_install.sh)
2. Verify the installation using
_"helm version --tls"_.  The output should resemble something like this:
```
helm version --tls
Client: &version.Version{SemVer:"v2.9.1", GitCommit:"20adb27c7c5868466912eebdf6664e7390ebe710", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.9.1", GitCommit:"20adb27c7c5868466912eebdf6664e7390ebe710", GitTreeState:"clean"}
```

## Set Up a Registry
1. Go to [IBM Cloud](https://cloud.ibm.com) and select "Kubernetes" then "Registry".  Follow the directions "Registry Quick Start" to create a registry.  Take note of the namespace you created.
2. At the top of the web page, select "Manage" then "Access (IAM)". On the left side panel, select "IBM Cloud API keys" and then click the button "Create an IBM Cloud API key".  Make sure to save your key. ![LoginScreen](https://pages.github.ibm.com/CASE/cloudpak-onboard-residency/assets/img/cp4d/manageiam.jpg)
3. Back in the shell, enter the following to login into the registry.
_"docker login us.icr.io/[your-registry-namespace] -u iamapikey -p [your-iam-key]"_

## Get the Add-On to be Installed
1. For this example, the "Watson Machine Learning" add-on tar will be used.  Download the add-on code and place it somewhere like "/ibm/modules"

## Install the Add-On
1. _"./deploy.sh -o -d /ibm/modules/watson_machine_learning.tar"_

## Installation Progress
The following shows the output you will see upon a successful "Watson Machine Learning" add-on installation.
```
The following environment variables will be used during the installation:
-----------------------------------------------------------------------------
namespace:                       zen
clusterDockerImagePrefix:        us.icr.io/cp4d2101
externalDockerImagePrefix:       us.icr.io/cp4d2101
useDynamicProvisioning:          true
storageClassName:                ibmc-file-gold
-----------------------------------------------------------------------------
If these values are not correct, type N to go back and change it.
Please type (Y) to proceed or (N) to exit the installation: y
Docker version found: 1.13.1
Docker config file found: /root/.docker/config.json
Kubernetes version found: Server Version: v1.11.0+d4cacc0
Kubernetes config file found: /root/.kube/config
kubectl is working
Openshift binary found: oc v3.11.141
Loading images
/ibm/InstallPackage/modules/wml//images
Loaded Images [==============================================================================] 6m41s (17/17) done
Pushed Images [==============================================================================] 26m54s (17/17) done
Deploying the chart as name wml
Running command: /ibm/InstallPackage/components/dpctl --config /ibm/InstallPackage/components/install.yaml helm rewriteChart -i /ibm/InstallPackage/modules/wml//charts/*.tgz -o /ibm/InstallPackage/modules/wml//charts/updated_wml.tgz
Running command: /ibm/InstallPackage/components/dpctl --config /ibm/InstallPackage/components/install.yaml helm installChart -f /ibm/InstallPackage/components/global.yaml   -r zen-wml -n zen -c /ibm/InstallPackage/modules/wml//charts/updated_wml.tgz 
Starting the installation ...
Package  Release zen-wml installed.
Running command: /ibm/InstallPackage/components/dpctl --config /ibm/InstallPackage/components/install.yaml helm waitChartReady -r zen-wml -t 60
Pods:         [==============================================================================] 7m3s (13/13) done
PVCs:         [==============================================================================] 1m35s (2/2) done
Deployments:  [==============================================================================] 5m52s (5/5) done
StatefulSets: [==============================================================================] 7m2s (2/2) done
The deploy script finished successfully
```

