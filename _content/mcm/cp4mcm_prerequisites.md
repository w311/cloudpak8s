---
title: Prerequisites
weight: 100
---
- 
# ensure there is a space after the - for the TOC to generate
{:toc}

# Multicloud Manager (MCM)

### The minimum hardware requirements:

Single node requirements

| Requirement | All management services enabled | All management services including logging disabled |
| :---------- | :-----------------------------: | :------------------------------------------------: |
| Number of hosts | 1 | 1 |
| Cores | 16 | 16 |
| CPU | >=2.4 GHz | >=2.4 GHz |
| RAM | 32 GB | 32 GB |
| Free disk space to install | >=200 GB | >=150 GB |

### The persistent storage requirements:

| Persistent Storage | Size (GB) | Recommended | Access | Comments |
| :----------------- | :-------: | :---------: | :----: | :------- |
| etcd | 1 | File Storage  | RWX | Required |

### Supported Platforms:

| Managed | Public | Private |
| :------ | :----- | :------ |
| IBM Redhat OpenShift | OCP | OCP |
| Managed OpenShift on AWS |  |  |
| Managed OpenShift on Azure  |  |  |

### Required Ports:

| Port | Access Type | Usage |
| :--: | :---------: | :---- |
| 8001 | External * | default for managed cluster to communicate with Kubernetes API server port on the hub cluster |
| 8500 | External * | default for managed cluster to communicate with Docker registry on the hub cluster |
| 443	 | External * |default for hub cluster to communicate with Klusterlet service on IBM Cloud Private nginx ingress |

*External - port must be open to allow connections from outside the cluster.

### Managed clusters:

| Cloud Type | List |
| :--------: | :--- |
| Managed | IBM Redhat OpenShift | 
| Public  | OCP , IKS , EKS , AKS , GKE |
| Private | OCP , Vmware |

Hardware requirements for managed clusters

| Component | CPU request | CPU limit | Memory request | Memory limit |
| :-------- | :---------: | :-------: | :------------: | :----------: |
| coredns | 100m | 500m | 70Mi | 170Mi |
| service-registry | 100m | 500m | 128Mi | 256Mi |
| connection-manager | 100m | 500m | 128Mi | 256Mi |
| klusterlet | 200m | 1000m | 128Mi | 500Mi |
| policy-compliance | 25m | 250m | 128Mi | 256Mi |
| search-collector | 25m | 250m | 128Mi | 256Mi |

# Cloud Automation Manager (CAM)

#### IBM Passport Advantage (PPA) part numbers

| eImage descriptions | file name | Part number |
| :------------------ | :-------: | :---------: |
| IBM Cloud Private 3.2 for Linux (x86_64) Cloud Automation Manager 3.2.1 | icp-cam-x86_64-3.2.0.tar.gz | CC2IUEN |


### The minimum hardware requirements:

**Note:** 
- Ensure the processes, such as Prometheus and logstash, are running and all requirements are met.
- Cloud Automation Manager will consume worker node resources

| Cloud Automation Manager size	| Worker nodes | vCPU	| Memory (GB)	| Notes |
| :---------------------------- | :----------: | :--: | :---------: | :---- |
| Single node deployment | 1	| 12 | >30 | |
| Single node deployment without metering | 1 | 12 | >20 | |
| High availability configuration | 3 | 4 per node | 16 GB per node |	|
| High concurrent deployment requirements (above 10) | 3 | 6 per node | 20 GB per node | 2vCPU 4 GB memory for every additional 10 concurrent deployments |
| Large number of deployed instances | 3 | 5 per node | 16 GB per node | 1vCPU for every 15K deployments managed |

### The persistent storage requirements:

**Note:** User must create persistent volumes to store Cloud Automation Manager database and log data.

| Persistent Storage | Size (GB) | Recommended | Access | Comments |
| :----------------- | :-------: | :---------: | :----: | :------- |
| cam-mongo-pv       | 20 GB | File Storage  | RWX | 20GB for up to 10k deployments. Add 10 GB for each additional 10k deployments. |
| cam-logs-pv        | 10 GB | File Storage  | RWX | Static |
| cam-terraform-pv   | 15 GB | File Storage  | RWX | Usage can grow or shrink |
| cam-bpd-appdata-pv | 20 GB | File Storage  | RWX | The size grows based on the number of templates in local repository |

### Supported operating systems and platforms

- Cloud Automation Manager performs '**manage-to**' operations directly on the hypervisor and does not have any restriction on the operating system level requirement.
- To know more about minimum system requirements for setting up and running the middleware Content Runtime within a virtual machine, see [System requirements](https://www.ibm.com/support/knowledgecenter/SS2L37_3.2.1.0/content/cam_content_camc_requirements.html?view=kc).

### Other requirements

- Internet connectivity is required for deployments to public cloud providers like IBM Cloud, Amazon EC2, and Microsoft Azure.
- | Minimum browser supported |
  | :-----------------------: |
  | Firefox 52 |
  | Chrome 57 |
  | Safari 10.1 |
  | Edge 16 |
- Additional resources and configuration may be required based on the desired use of automation content available with Cloud Automation Manager. To understand the automation content available for use, see [About Cloud Automation Manager Content](https://www.ibm.com/support/knowledgecenter/SS2L37_3.2.1.0/content/cam_content_overview_summary.html?view=kc).

- Elevated privileges are required. For more information, see [Prerequisites for installing Cloud Automation Manager](https://www.ibm.com/support/knowledgecenter/SS2L37_3.2.1.0/cam_prereq.html?view=kc).

# IBM Cloud App Management (iCAM)

#### IBM Passport Advantage (PPA) part numbers

**Note**: visit [IBM Cloud App Management components](https://www.ibm.com/support/knowledgecenter/SS8G7U_19.2.1/com.ibm.app.mgmt.doc/content/install_download_pm_part_no.html) for a list of additional items and respective part numbers.

| eImage descriptions | file name | Part number |
| :------------------ | :-------: | :---------: |
| IBM Cloud App Management V2019.2.1 Server Install xlinux | app_mgmt_server_2019.2.1.tar.gz | CC2DXEN |
| IBM Cloud App Management  V2019.2.1 for Eventing Klusterlet Config on AMD64 | agent_ppa_2019.2.1_prod_amd64.tar.gz | CC2LSEN |

### The minimum hardware requirements:

**Note: Demonstration/Proof of Concept**
This is a Size0 environment requirement. This size is suitable for a very small demonstration, trial or proof of concept. It is only suitable for a minimal workload. This size is designed to reduce the size of the microservices deployed to minimize the required hardware.

| Approx resources (Agents, Data Collectors) | Metrics per minute | Number of VMs/hosts | CPU (cores) | RAM (GB) | Disk (GB) |
| :---------------------------: | :----------------: | :-------------------: | :---------: | :------: | :-------: |
| Up to 100 | Up to 25000 | 2 | 12 | 32 | 100 |

### The persistent storage requirements:

**Note** visit [Configuring the disk drives for the said services](https://www.ibm.com/support/knowledgecenter/SS8G7U_19.2.1/com.ibm.app.mgmt.doc/content/install_storage_formatdrive.html) for additional details

| Persistent Storage | Size (GB) | Recommended | Access | Comments |
| :----------------- | :-------: | :---------: | :----: | :------- |
| Cassandra | 50 | Local, vSphere, File Storage | RWX | Required |
| Couch DB  | 5  | Local, vSphere, File Storage | RWX | Required |
| DataStore | 5 | Local, vSphere, File Storage | RWX | Required |
| Zookeeper | 1 | Local, vSphere, File Storage | RWX | Required |
| Kafka Broker | 5 | Local, vSphere, File Storage | RWX | Required |

#### Supported Operating Systems

| Operating System | OS Minimum | Hardware | Bitness | Components |
| :--------------- | :--------: | :------: | :-----: | :--------: |
| RHEL Server 7 | 7.3 | x86-64 | 64-Exploit | Server |
| Ubuntu 16.04 LTS | Base | x86-64 | 64-Exploit | Server |
