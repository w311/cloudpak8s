---
title: Prerequisites
weight: 200
---


## Openshift cluster Requirement

   1 A provisioned OpenShift cluster. The minimum recommended configuration is a three-node cluster with 16 CPUs and 64 GB of memory on each of the worker nodes.
   
   2 Ensure the cluster is able to connect to the Internet, which is required for pulling the pod images.
   
   3 Ensure you have a connection to the cluster, and have cluster-admin permissions. The *cluster-admin* role must also be set for the service accounts default and icpd-anyuid-sa.
   
   4 A Mac or Linux machine inside the cluster to run the installation scripts from.
    
## Requested PersistentVolumeClaim (PVC) size

   Ensure that the PVC that you plan use for Cloud Pak for Data has a minimum of 700 GB of storage space.
   
   If you plan to install add-ons to Cloud Pak for Data, allocate additional VPCs and memory to Cloud Pak for Data.

## Docker registry

   Ensure that the Docker registry has a minimum of 150 GB of storage space.
   
   If you plan to install add-ons to Cloud Pak for Data, allocate additional storage space to the Docker registry.
   
## IBM Knowledge Center Link

   
   [System requirements for Cloud Pak for Data in an existing IBM Cloud Private installation](https://www.ibm.com/support/knowledgecenter/en/SSQNUZ_2.1.0/com.ibm.icpdata.doc/zen/install/reqs-exist-icp-inst.html)
   
   [Installing Cloud Pak for Data on managed Red Hat OpenShift on IBM Cloud](https://www.ibm.com/support/knowledgecenter/en/SSQNUZ_2.1.0/com.ibm.icpdata.doc/zen/install/openshift-softlayer.html)
