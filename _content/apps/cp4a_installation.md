---
title: Install on OpenShift Container Platform
weight: 200
---

## Cloud Pak for Applications Installer

The Cloud Pak for Applications Installer installs the following components on your Red Hat OpenShift Container Platform cluster:
- IBM Kabanero Enterprise
- IBM Cloud Transformation Advisor

These components install into an existing clusters including an on-premises cluster or Red Hat OpenShift on IBM Cloud  service.  
OpenShift can be obtained through the Cloud Pak or a Red Hat OpenShift subscription.

[Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSCSJL/install-icpa-cli.html) details how to use the installer command line. 

## Cloud Pak for Applications Installer

The Cloud Pak for Applications Installer installs the following components on your OCP Cluster:
- Kabanero Enterprise
- Transformation Advisor

Only installation from an entitled registry is supported.  
Air gapped installations are **not** supported.  
The installer must have access to both the entitled registry and the target cluster from the same workstation.  

### Prerequisites

The [prerequisites](https://www.ibm.com/support/knowledgecenter/SSCSJL/install-prerequisites.html) include Red Hat OpenShift Container Platform (OCP) version 3.11.

### Installation

The full set of [instructions for installing Cloud Pak for Applications](https://www.ibm.com/support/knowledgecenter/SSCSJL/install-icpa-cli.html) is found in the IBM Knowledge Center.  The installation can per performed from a workstation that is not one of the VMs in the cluster.  This workstation must have access to the entitled registry, the OCP/OKD cluster and the Internet.  

If the OCP/OKD app subdomain is set in the cluster, there is no need to edit the generated config.yaml file.  The installation can be started with all default values.

### Workarounds for Kabanero Enterprise

In version `3.0.0.0` of Kabanero Enterprise the appsody operator can only deploy applications in the `kabanero` namespace.

To work around this problem a second appsody operator needs to be deployed with a cluster scope that watches all namespaces.

Take into account that the namespace `kabanero` will be watched by both appsody operators, this means that no applications should be depoyed into the `kabanero` namespace. 
The user is required to set the namespace in the `app-deploy.yaml` in the appsody application git repository.


#### Install the Appsody Operator CRD
```
oc apply -f https://raw.githubusercontent.com/appsody/appsody-operator/master/deploy/releases/0.1.0/appsody-app-crd.yaml
```

#### Install the Appsody Operator RBAC resources
Create a namespace to install the appsody operator for example `appsody` if not already created.
```
oc new-project appsody
```

Set the environment variable `OPERATOR_NAMESPACE` to the namespace `appsody`
```
OPERATOR_NAMESPACE=appsody
```
With the variable `OPERATOR_NAMESPACE` set run the following command:
```
curl -L https://raw.githubusercontent.com/appsody/appsody-operator/master/deploy/releases/0.1.0/appsody-app-cluster-rbac.yaml \
  | sed -e "s/APPSODY_OPERATOR_NAMESPACE/${OPERATOR_NAMESPACE}/" \
  | oc apply -f -
 ```

#### Install the Appsody Operator resources

Set the variable `WATCH_NAMESPACE` to empty string value to watch all namespaces
```
WATCH_NAMESPACE='""'
```
Then run the following command
```
curl -L https://raw.githubusercontent.com/appsody/appsody-operator/master/deploy/releases/0.1.0/appsody-app-operator.yaml \
  | sed -e "s/APPSODY_WATCH_NAMESPACE/${WATCH_NAMESPACE}/" \
  | oc apply -n ${OPERATOR_NAMESPACE} -f -
```


The cluster setup of Cloud Pak for Applications is complete.
