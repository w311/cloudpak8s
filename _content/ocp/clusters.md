---
title: Consolidated Cloud Pack Sizing Matrix
weight: 800
---

- 
{:toc}

## CloudPak Sizing Requirements for OCP Instances

In the sizing exercise, we only considered the worker node sizes and provisioned non-HA instances for each Openshift cluster on VMware.  All Openshift nodes are standard sizes.

* Each cluster does not include Openshift monitoring, metrics, or logging due to resource constraints.  These can be enabled later using ansible playbooks from the bastion host.

* When block storage is required by the Cloud Pak, we provisioned vSphere volume storage class.  When file storage is required, we provisioned GlusterFS in converged mode.
  
| Node role (# nodes x core x RAM x docker disk storage) | CP4MCM  | CP4A | CP4I | CP4D| CP4APP |
| --- | --- | --- | --- | --- | --- | --- |
| bastion | 1 x 2 x 4 x 32 | 1 x 2 x 4 x 32 | 1 x 2 x 4 x 32 | 1 x 2 x 4 x 32 | 1 x 2 x 4 x 32 |
| master |  1 x 8 x 32 x 100 | 1 x 8 x 32 x 100 | 1 x 8 x 32 x 100 | 1 x 8 x 32 x 100 | 1 x 8 x 32 x 100   |
| infra |  1 x 8 x 32 x 100 | 1 x 8 x 32 x 100 | 1 x 8 x 32 x 100 | 1 x 8 x 32 x 100 | 1 x 8 x 32 x 100 |
| compute / worker | 2 x 16 x 32 x 100 | 5 x 8 x 32 x 100 | 7 x 16 x 32 x 100 | 4 x 16 x 64 x 200 | 2 x 8 x 32 x 100 |
| DB2 VM |   | 1 X 16 x 32 X 200 |   |   |   |
| PV STORAGE | 65 GB block | 100 GB file | 650 GB block, 100 GB file  | 800 GB file | n/a   | 

* snowflakes/notes:
  * CP4A requires customer to have DB2 server running outside of the OCP cluster

## Sample `terraform.tfvars`

For each Cloud Pak, the following clusters were provisioned using the provided [Terraform template](https://github.com/ibm-cloud-architecture/terraform-openshift3-vmware-example)

| CloudPak | File |
| -- | -- |
| Cloud Pak for Data | [cp4d-terraform.tfvars]({{ site.static_file }}/ocp/tfvars/cp4d-terraform.tfvars) |
| Cloud Pak for Multi Cloud Management | [cp4mcm-terraform.tfvars]({{ site.static_file }}/ocp/tfvars/cp4mcm-terraform.tfvars) |
| Cloud Pak for Automation | [cp4a-terraform.tfvars]({{ site.static_file }}/ocp/tfvars/cp4a-terraform.tfvars) |
| Cloud Pak for Integration |  [cp4i-terraform.tfvars]({{ site.static_file }}/ocp/tfvars/cp4i-terraform.tfvars)|
| Cloud Pak for Apps | [cp4app-terraform.tfvars]({{ site.static_file }}/ocp/tfvars/cp4app-terraform.tfvars) |


