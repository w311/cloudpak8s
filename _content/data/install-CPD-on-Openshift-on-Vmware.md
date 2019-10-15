---
title: Install Cloud Pak for Data on Vmware OpenShift
weight: 600
---

## 1. Preparing for Cloud Pak for Data Install
IBM Cloud Pak for Data Install requires a fully functional OpenShift 3.11 cluster and the following cluster requirements:
- 3 Worker nodes with 16 vpc each with 64 GB RAM (48 VPC total). All worker nodes should be able to schedule jobs
- 800 GB of available persistent storage for CP4D only (example: glusterfs)
- cluster admin role
- Access to Docker/tiller and able to push/pull

** Openshift cluster provisioning using terraform is documented [here](https://pages.github.ibm.com/CASE/cloudpak-onboard-residency/data/install-Openshift-On-Vmware)


## 2. Installing Cloud Pak for Data from a openshift client machine (Linux/Mac/Windows machine or your laptop ?)
- Step 1: Download the Openshift Client tool on your client machine
- Step 2: Configure the OC client to access the OCP cluster
      ![copy command](https://github.ibm.com/CASE/cloudpak-onboard-residency/blob/gh-pages/assets/img/cp4d/oc-client-config.jpg)
- copy login command from OpenShift dashboard to your terminal shell
     
``` 
      $ oc login https://boa2102.demo.ibmcloudpack.com:8443 --token=PV717cA-9094hnI16tRsVbJZEX2El0ScJmUPUf2Hxxk
```
- Step 3: Test the OCP using following commands to ensure, you are able to list the nodes and projects in ocp.
```
  $ oc get nodes
  $ oc get projects
```

## 3. Creating Install script
create a new <b>install-cp4data.sh</b> installation script with the following content:
```
#!/bin/bash
#******************************************************************************
# Licensed Materials - Property of IBM
# (c) Copyright IBM Corporation 2019. All Rights Reserved.
#
# Note to U.S. Government Users Restricted Rights:
# Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
#******************************************************************************

if [[ -z $1 ]]; then
    echo "Usage: ./install-cp4data.sh <<namespace>>"
    exit 1
fi

NAMESPACE=$1
DOCKER_REGISTRY="cp.stg.icr.io/cp/cp4d"
DOCKER_REGISTRY_USER="iamapikey"
DOCKER_REGISTRY_PASS="<<inform_here_the_docker_password>>"

oc create ns ${NAMESPACE}

oc project ${NAMESPACE}

oc create sa -n ${NAMESPACE} default
oc create sa -n ${NAMESPACE} tiller

# Add `deployer` serviceaccount to `system:deployer` role to allow the template kickstart
oc -n ${NAMESPACE} adm policy add-role-to-user -z deployer system:deployer

# Create the secrets to pull images from the docker repository
oc create secret docker-registry icp4d-anyuid-docker-pull -n ${NAMESPACE} --docker-server=${DOCKER_REGISTRY} --docker-username=${DOCKER_REGISTRY_USER} --docker-password=${DOCKER_REGISTRY_PASS} --docker-email=cp4data@ibm.com
oc secrets -n ${NAMESPACE} link default icp4d-anyuid-docker-pull --for=pull


# Set the Security Context -  One scc is created for every namespace
cat << EOF | oc apply -f - 
allowHostDirVolumePlugin: true
allowHostIPC: true
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowedCapabilities:
- '*'
allowedFlexVolumes: null
apiVersion: v1
defaultAddCapabilities: []
fsGroup:
  type: RunAsAny
groups:
- cluster-admins
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: zenuid provides all features of the restricted SCC but allows users to run with any UID and any GID.
  name: ${NAMESPACE}-zenuid
priority: 10
readOnlyRootFilesystem: false
requiredDropCapabilities: []
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
users: 
- system:serviceaccount:${NAMESPACE}:default
- system:serviceaccount:${NAMESPACE}:icpd-anyuid-sa
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret

EOF

# Give cluster-admin permission to the service accounts used on the installation
oc adm policy add-cluster-role-to-user cluster-admin "system:serviceaccount:${NAMESPACE}:tiller"
oc adm policy add-cluster-role-to-user cluster-admin "system:serviceaccount:${NAMESPACE}:default"


# Set the template for the catalog
cat << EOF | oc apply -f - 
---
apiVersion: template.openshift.io/v1
kind: Template
message: |-
  The following service(s) have been created in your project: ${NAMESPACE}.

        Username: admin
        Password: password
        CP4Data URL: https://${CP4D_ROUTE}:${CP4D_PORT_NUMBER}/

  For more information about, see https://docs-icpdata.mybluemix.net/home.
metadata:
  name: cp4data
  annotations:
    description: |-
      IBM® Cloud Pak for Data is a native cloud solution that enables you to put your data to work quickly and efficiently.
    openshift.io/display-name: Cloud Pak for Data
    openshift.io/documentation-url: https://docs-icpdata.mybluemix.net/home
    openshift.io/long-description: IBM Cloud Pak for Data is composed of pre-configured microservices that run on a multi-node IBM Cloud Private cluster. The microservices enable you to connect to your data sources so that you can catalog and govern, explore and profile, transform, and analyze your data from a single web application..
    openshift.io/provider-display-name: Red Hat, Inc.
    openshift.io/support-url: https://access.redhat.com
    tags: AI, Machine Learning, Data Management, IBM
objects:
- apiVersion: v1
  kind: DeploymentConfig
  metadata:
    name: cp4data-installer
    annotations:
      template.alpha.openshift.io/wait-for-ready: "true"
  spec:
    replicas: 1
    selector:
      name: cp4data-installer
    strategy:
      type: Recreate
    template:
      metadata:
        labels:
          name: cp4data-installer
      spec:
        containers:
        - env:
          - name: NAMESPACE
            value: \${NAMESPACE}
          - name: TILLER_NAMESPACE
            value: \${NAMESPACE}
          - name: INSTALL_TILLER
            value: "1"
          - name: TILLER_IMAGE
            value: "${DOCKER_REGISTRY}/cp4d-tiller:v1"
          - name: TILLER_TLS
            value: "0"
          - name: STORAGE_CLASS
            value: \${STORAGE_CLASS}
          - name: DOCKER_REGISTRY
            value: ${DOCKER_REGISTRY}
          - name: DOCKER_REGISTRY_USER 
            value: ${DOCKER_REGISTRY_USER}
          - name: DOCKER_REGISTRY_PASS
            value: \${DOCKER_REGISTRY_PASS}
          - name: NGINX_PORT_NUMBER
            value: \${NGINX_PORT_NUMBER}
          - name: CONSOLE_ROUTE_PREFIX
            value: \${CONSOLE_ROUTE_PREFIX}
          name: cp4data-installer
          image: "${DOCKER_REGISTRY}/cp4d-installer:v1"
          imagePullPolicy: Always
          resources:
            limits:
              memory: "200Mi"
              cpu: 1
          command: [ "/bin/sh", "-c" ]
          args: [ "./deploy-cp4data.sh; sleep 3000000" ]
        imagePullSecrets:
        - name: icp4d-anyuid-docker-pull   
parameters:
- description: Namespace where to install Cloud Pak for Data.
  displayName: Namespace
  name: NAMESPACE
  required: true
  value: ${NAMESPACE}
- description: Docker registry user with permission with pull images.
  displayName: Docker Registry User
  name: DOCKER_REGISTRY_USER
  value: "iamapikey"
  required: true
- description: Docker registry password.
  displayName: Docker Registry Password
  name: DOCKER_REGISTRY_PASS
  required: true
  value: inform_here_the_docker_repo_password
- description: Hostname for the external route.
  displayName: Cloud Pak route hostname
  name: CONSOLE_ROUTE_PREFIX
  required: true
  value: "cp4data-console"
- description: Storage class name.
  displayName: StorageClass
  name: STORAGE_CLASS
  value: "glusterfs-storage"
  required: true
 
EOF
```

## 3. Running the command

## Update entitlement registry details in the script <b>install-cp4data.sh</b> before executing it.

- DOCKER_REGISTRY="cp.stg.icr.io/cp/cp4d"
- DOCKER_REGISTRY_USER="iamapikey"
- DOCKER_REGISTRY_PASS="<<inform here the docker password>>"    

*** <b>Please contact Offering Management</b>

Then run the above script to create <b>"Cloud Pak for Data"</b> install tile on your OCP Catalogue.
```
# ./install-cp4data.sh <new_namespace>

Example:
# ./install-cp4data.sh lax-ai
namespace/lax-ai created
Now using project "lax-ai" on server "https://boa2102.demo.ibmcloudpack.com:8443".
Error from server (AlreadyExists): serviceaccounts "default" already exists
serviceaccount/tiller created
role "system:deployer" added: "deployer"
secret/icp4d-anyuid-docker-pull created
securitycontextconstraints.security.openshift.io/lax-ai-zenuid created
cluster role "cluster-admin" added: "system:serviceaccount:lax-ai:tiller"
cluster role "cluster-admin" added: "system:serviceaccount:lax-ai:default"
template.template.openshift.io/cp4data created
#
```


## 4 Install "Cloud Pak for Data" from  OpenShift Admin dashboard

Please ensure, what <b>storage class</b> is supported in your cluster using the following command
```
# oc get sc
NAME                PROVISIONER               AGE
glusterfs-storage   kubernetes.io/glusterfs   13d
```
in this case, <b>glusterfs-storage</b> is the available storage class.

on OpenShift Admin Console, 
![tile](https://github.ibm.com/CASE/cloudpak-onboard-residency/blob/gh-pages/assets/img/cp4d/selecting-cp4d-installer.jpg)
- 1. select "Application Console" 
- 2. Search for "Cloud Pak for Data tile"
- 3. Click the tile to bring up a form to enter addtional details
![details](https://github.ibm.com/CASE/cloudpak-onboard-residency/blob/gh-pages/assets/img/cp4d/storage-class.jpg)
      - Namespace
      - Docker Registry User
      - Docker Registry Password
      - Cloud Pak route hostname
      - StorageClass

- Select <b>Create</b> to start the install.

      This installer will setup a tiller and pull the Cloud Pak for Data helm charts from the entitlement registry and deploy them inside the OCP cluster under the namespace. 
      

## 5 Monitoring the Install
You can monitor the install log by check the example <b>"cp4data-installer-1-xl2d9"</b> pod's log. This takes above 45 minutes to install the Cloud Pak for Data platform and add-on modules like DDE and UGI.

If you notice any error, please delete the install pod and let it re-run. Most of the cases, the error is caused by the timing delay.

On successfull install, install pod log will show the URL of the CP4D dashboard.  

## Cloud Pak for Data Dashboard URL
You can also get the URL from OCP Admin dashboard under the "Application Console" of your namespace/project. Select the Routes to see the URL.
![CP4D URL](https://github.ibm.com/CASE/cloudpak-onboard-residency/blob/gh-pages/assets/img/cp4d/getting%20CP4D-URL.jpg)


## 6 Document References
- https://www.ibm.com/support/knowledgecenter/en/SSQNUZ_2.1.0/com.ibm.icpdata.doc/zen/install/openshift-softlayer.html

## 6. Troubleshooting
1. **ibm-daas-redis** pod is pending for PV creation
```
$ oc get pod --all-namespaces | grep -i -v running
NAMESPACE                           NAME                                                        READY     STATUS      RESTARTS   AGE
cp4d-lax                            cloudant-permissions-hook-qwkpd                             0/1       Completed   0          1h
cp4d-lax                            cp4d-lax-ibm-daas-daas-proxy-57b8478fdf-2gl66               0/2       Init:0/1    0          1h
cp4d-lax                            cp4d-lax-ibm-daas-daas-proxy-57b8478fdf-btj2h               0/2       Init:0/1    0          1h
cp4d-lax                            cp4d-lax-ibm-daas-redis-6d95b77585-wp6n4                    0/1       Pending     0          1h
cp4d-lax                            dash-post-install-job-4lx5h                                 0/1       Completed   0          1h
cp4d-lax                            dsx-influxdb-set-auth-ckw6h                                 0/1       Completed   3          1h
cp4d-lax                            dsx-requisite-pre-install-job-mlxg2                         0/1       Completed   0          1h
cp4d-lax                            preload-jupyterpy36-job-frnnj                               0/1       Completed   0          1h
cp4d-lax                            preload-jupyterpy36-job-h2wsb                               0/1       Completed   0          1h
cp4d-lax                            preload-jupyterpy36-job-q9wxg                               0/1       Completed   0          1h
cp4d-lax                            setup-nginx-job-gkxc6                                       0/1       Completed   0          1h
cp4d-lax                            zen-base-copy-files-pre-install-job-hh2s6                   0/1       Completed   0          1h
cp4d-lax                            zen-metastoredb-init-9gcdx                                  0/1       Completed   0          1h
cp4d-lax                            zen-metastoredbdb-init-wfktl                                0/1       Completed   0          1h
```

Solution:  Describe pod for getting more details. Example
```
# oc describe pod  cp4d-lax-ibm-daas-redis-6d95b77585-wp6n4 -n cp4d-lax
Name:               cp4d-lax-ibm-daas-redis-6d95b77585-wp6n4
Namespace:          cp4d-lax
Priority:           0
PriorityClassName:  <none>
Node:               <none>
Labels:             app=cp4d-lax-ibm-daas-redis
                    pod-template-hash=2851633141
Annotations:        openshift.io/scc=anyuid
                    productID=ICP4D-IBMCognosDashboardEmbedded_01319_PROD_00000
                    productName=IBM Cognos Dashboard Embedded
                    productVersion=0.13.19
Status:             Pending
IP:                 
Controlled By:      ReplicaSet/cp4d-lax-ibm-daas-redis-6d95b77585
Containers:
  cp4d-lax-ibm-daas-redis:
    Image:      us.icr.io/release2_1_0_1_base/redis:1.0.3
    Port:       6379/TCP
    Host Port:  0/TCP
    Requests:
      cpu:      100m
      memory:   256Mi
    Liveness:   exec [redis-cli ping] delay=30s timeout=5s period=10s #success=1 #failure=3
    Readiness:  exec [redis-cli ping] delay=5s timeout=1s period=10s #success=1 #failure=3
    Environment:
      ALLOW_EMPTY_PASSWORD:  yes
    Mounts:
      /bitnami from redis-data (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-n5x9p (ro)
Conditions:
  Type           Status
  PodScheduled   False 
Volumes:
  redis-data:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  cp4d-lax-ibm-daas-redis
    ReadOnly:   false
  default-token-n5x9p:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-n5x9p
    Optional:    false
QoS Class:       Burstable
Node-Selectors:  beta.kubernetes.io/arch=amd64
                 node-role.kubernetes.io/compute=true
Tolerations:     node.kubernetes.io/memory-pressure:NoSchedule
Events:
  Type     Reason            Age                 From               Message
  ----     ------            ----                ----               -------
  Warning  FailedScheduling  4m (x3572 over 1h)  default-scheduler  pod has unbound PersistentVolumeClaims (repeated 6 times)


# oc get pvc
NAME                        STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS        AGE
cloudant-srv-mount          Bound     pvc-8378ed9b-d502-11e9-995d-06a6476a5489   10Gi       RWX            glusterfs-storage   1h
cp4d-lax-ibm-daas-daas      Bound     pvc-94f81b75-d504-11e9-995d-06a6476a5489   20Gi       RWX            glusterfs-storage   1h
cp4d-lax-ibm-daas-redis     Pending                                                                                            1h
datadir-zen-metastoredb-0   Bound     pvc-83a03288-d502-11e9-9b18-06e451a5477f   10Gi       RWO            glusterfs-storage   1h
datadir-zen-metastoredb-1   Bound     pvc-83aa60f1-d502-11e9-9b18-06e451a5477f   10Gi       RWO            glusterfs-storage   1h
datadir-zen-metastoredb-2   Bound     pvc-83b61599-d502-11e9-9b18-06e451a5477f   10Gi       RWO            glusterfs-storage   1h
influxdb-pvc                Bound     pvc-8377d81a-d502-11e9-995d-06a6476a5489   10Gi       RWX            glusterfs-storage   1h
redis-mount                 Bound     pvc-837a98f1-d502-11e9-995d-06a6476a5489   10Gi       RWX            glusterfs-storage   1h
spark-metrics-pvc           Bound     pvc-837bd0f8-d502-11e9-995d-06a6476a5489   50Gi       RWX            glusterfs-storage   1h
user-home-pvc               Bound     pvc-6f061bc6-d502-11e9-995d-06a6476a5489   100Gi      RWX            glusterfs-storage   1h
zen-ai-ibm-daas-redis       Bound     pvc-4060c3af-d510-11e9-995d-06a6476a5489   8Gi        RWO            glusterfs-storage   3m
```
```
# cat ibm-daas-redis-pv.yaml 
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  finalizers:
  - kubernetes.io/pvc-protection
  labels:
    app: cp4d-lax-ibm-daas-redis
    chart: redis-1.1.6
    heritage: Tiller
    release: cp4d-lax-ibm-daas
  name: cp4d-lax-ibm-daas-redis
  namespace: cp4d-lax
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 8Gi
  storageClassName: glusterfs-storage

a. Delete the pending unbound PVC
#oc delete pvc zen-ai-ibm-daas-redis 

b. Create PV/PVCs.
#oc apply -f ibm-daas-redis-pv.yaml

```
