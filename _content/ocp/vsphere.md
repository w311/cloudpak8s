---
title: Installing Openshift 3.x on vSphere
weight: 240
---

- 
{:toc}

[VMware vSphere](https://www.vmware.com/ca/products/vsphere.html) is a server virtualization software used to automate datacenter operations.  In on-premises scenarios, we can provision virtual machines in vSphere and install Openshift on top of them in order to get the container orchestration platform necessary to run the cloud paks.

When using VMware vSphere, it is recommended to use the [vSphere Storage Provider](https://vmware.github.io/vsphere-storage-for-kubernetes/documentation/) to allow dynamic provisioning of block storage for Cloud Paks.  This should be configured in the inventory file during installation following these instructions: [https://docs.openshift.com/container-platform/3.11/install_config/configuring_vsphere.html](https://docs.openshift.com/container-platform/3.11/install_config/configuring_vsphere.html).  The automated terraform-based installation will configure this automatically.

For file storage requirements, we tested GlusterFS, but NFS should also work as well.  GlusterFS has the added benefit of an in-tree dynamic storage provisioner: [https://docs.openshift.com/container-platform/3.11/install_config/storage_examples/gluster_dynamic_example.html#dynamic-provisioning](https://docs.openshift.com/container-platform/3.11/install_config/storage_examples/gluster_dynamic_example.html#dynamic-provisioning)

In disconnected installations, there may be additional steps to follow: [https://docs.openshift.com/container-platform/3.11/install/disconnected_install.html](https://docs.openshift.com/container-platform/3.11/install/disconnected_install.html) 

Here are the tested and recommended infrastructure components we used to evaluate Cloud Paks installed on Openshift on vSphere:

|Component|Tested|Recommended|
|-|-|-|
|Load Balancer|none (non-HA), or HAProxy (pseudo-HA)|F5 BIGIP or other appliance|
|DNS|`/etc/hosts` for internal cluster, [bind9](https://www.isc.org/bind/) (in VM) for wildcard domain|highly-available DNS|
|Certificates (for console and routes)|self-signed|internal PKI|
|Block Storage|vSphere volume|vSphere volume|
|File Storage|GlusterFS|GlusterFS or NFS|
|Registry Volume type|vSphere Volume, GlusterFS|GlusterFS|
|Identity|htpasswd|LDAP or OIDC provider|

{% include_relative RHEL_template.md %}

{% include_relative openshift3_manual_installation_vsphere.md %}

{% include_relative openshift3_terraform_installation_vsphere.md %}