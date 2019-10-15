---
title: OCP 3.x Architecture
weight: 200
---

## OpenShift 3.x Architecture

OpenShift 3.x general architecture is shown in the following image. OpenShift 3.x is an implementation of Kubernetes cluster technology. Kubernetes is a container orchestration technology whose core concept is a cluster made up of various nodes. The OpenShift 3.x architecture includes the following types of nodes:

![Openshift 3.x architecture]({{ site.github.url }}/assets/ocp/openshift-architecture.png)

Most Openshift components are delivered themselves as container images that are pulled either over the internet through Redhat's [managed registry](https://registry.redhat.io), or an image registry mirror in disconnected installation scenarios.  All cluster nodes need to have a valid subscription for Red Hat Openshift.

- **Master nodes**: Master instances run the OpenShift master components, including the API server and etcd. The master components manages nodes in its Kubernetes cluster and schedules pods to run on nodes.  In high availability scenarios, these are deployed in odd numbers (3 or 5 nodes), which is required for quorum for the etcd distributed key store.
  
- **Worker (Application) nodes**: The Application (app) instances run the atomic-openshift-node service. These nodes run containers created by the end users of the OpenShift service.  Application workload is distributed across the worker nodes as scheduled by the Openshift scheduler.  For high availability, multiple replicas of an application can be provisioned across the worker nodes.
  
- **Infrastructure nodes**: The infrastructure nodes are essentially worker nodes that are sized and labeled in a particular way to have specific workload targeted to them. In larger installations, the nodes with the label `infra` can be dedicated to run Red Hat OpenShift Container Platform components such as the image registry, monitoring, and the router. If enabled, these nodes can also be used to host optional components such as metering, and logging components. Persistent storage should be available to the services running on these nodes.
  
- **Shared storage**: Container storage is ephemeral, meaning if the container is restarted, any state written to its local filesystem is lost. Some applications require persistent state, and this can be provided on volumes outside of the cluster. The container orchestration platform is responsible for the lifecycle of the volumes as well as mounting and unmounting the volumes from nodes along with the container lifecycle. Persistent Volume Claims (PVC) are used to request volumes and Persistent Volume objects represent volumes on external storage used to store the application data. The `StorageClass` object represents a particular type of storage used that applications can request. There are two main modes of storage in Kubernetes:
  - RWO (Read-Write Once) storage, where a single pod writes data to disk that needs to persist across container restarts or redployments. This is typically referred to or implemented as *block storage*. This works well for applications that already perform replication for consistency and availability, such as MongoDB.
  - RWX (Read-Write Many) storage, where more than one pod reads and writes to the same disk volumes.  This is commonly referred to or implemented as *file storage*.  For example, the when scaled out, Openshift image registry pods require the blobs storing the images to be the same across all instances of the registry in order to serve multiple clients with the same data.

  [Openshift Container Storage](https://www.openshift.com/products/container-storage/) is a Red Hat offering based on GlusterFS that can provide both block and file storage to containers.  In OCS 4, the offering will be based on Ceph.

- **Load balancer**: In high availability scenarios, an external load balancer serves as a single entry point to Red Hat OpenShift Container Platform components. Two different load balancers are used, one for control plane traffic (i.e. the Openshift API) and a separate one for the applications workloads running on Openshift that are exposed to application clients. Typically on-premises installations have a solution such as an F5 LTM that can be used to spread traffic between the master nodes for the control plane and infra nodes for client application traffic.  In POC or Demo scenarios, a VM running HAProxy may be used as a stand-in, but note that in production scenarios HAProxy can become a single point of failure. On public clouds, a load balancer service can be used that is able to scale with client traffic are recommended: for example AWS Elastic Load Balancer (ELB) service.

- **DNS** In OpenShift, DNS configuration is necessary to have all OpenShift routes and APIs are accessing this load balancer.  The control plane needs an external DNS name that clients accessing the API can resolve, and an internal DNS name that the cluster nodes use for internal communication.  The router requires a wildcard CNAME record that all application routes are published on.  Internally, all cluster nodes need to be able to resolve each others' host names.
  
- **Bastion host**: in air-gapped scenarios, a bastion host (sometimes called a control host) is a node outside of the cluster that is used to gain connectivity into a cluster. In many cases the node is fully exposed to attack by being on the public side of the DMZ, unprotected by a firewall or filtering router.  For Openshift 3.x installation purposes, we use this host to execute the ansible installation playbooks.  When Openshift is installed, this node can be removed.

External access to the OpenShift cluster are achieved using a load balancer that control access to OpenShift console and other application based routes.  For application deployment purposes, direct worker node access is not required and should be discouraged.  

