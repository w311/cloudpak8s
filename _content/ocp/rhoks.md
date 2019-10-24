---
title: Red Hat OpenShift on IBM Cloud
weight: 230
---

IBM Cloud provides a [managed Openshift](https://www.ibm.com/cloud/openshift) offering similar to the IBM Kubernetes Service (IKS) offering.  Users can provision a fully functional Openshift Cluster in a few clicks.

The underlying infrastructure is provided by [Virtual Server Instances (VSIs)](https://www.ibm.com/cloud/virtual-servers) on IBM Cloud Classic Infrastructure (SoftLayer).  The control plane is completely managed by IBM while the worker nodes are deployed in the customer's account.  The worker nodes may be deployed across multiple availability zones for additional resiliency.  

As the control plane is managed by IBM, the user only receives access to the Openshift API server and not SSH access to any nodes.  This is a good assumption in general when deploying Cloud Paks to Openshift; that you should not need to SSH into any cluster nodes and you will perform Cloud Pak installation from another node outside of the cluster.

Note that in RHOKS, the internal Openshift image registry is not exposed by default (the registry route is not created).  As the registry volume is also not sized very large, it is recommended to use [IBM Container Registry](https://www.ibm.com/cloud/container-registry) for any large image storage such as Cloud Pak image storage.  The internal Openshift image registry should mostly be used for S2I and as a local image cache.

Another caveat when using RHOKS is that all cluster users must be in IBM Cloud IAM.  At this time, Cloud Paks require a cluster-admin user, which means the user installing the Cloud Pak must be a super user of the cluster.  See [documentation](https://cloud.ibm.com/docs/containers?topic=containers-users) on assigning the correct access.  Once the Cloud Pak is installed, a separate IAM component manages access to the Cloud Pak services.

Using RHOKS on IBM Cloud provides the following infrastructure components:

|Component|Description|
|-|-|
|Load Balancer|Floating IP|
|DNS|IBM Cloud Internet Services (CIS)|
|Certificates (for console and routes)|LetsEncrypt (with automated renewal)|
|Block Storage|IBM Block Storage (SAN)|
|File Storage|IBM File Storage|
|Registry Volume|IBM File Storage - 20GB volume.  Use [IBM Cloud Registry (ICR)](https://www.ibm.com/cloud/container-registry) for large image storage|
|Identity|IBM Cloud IAM|

