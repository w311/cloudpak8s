---
title: Install Openshift on Vmware
weight: 500
---

## Download Github terraform openshift installation example and create terraform.tfvars file

  1 Download the github terraform openshift installation example from here:

   [terraform-openshift3-vmware-example](https://github.com/ibm-cloud-architecture/terraform-openshift3-vmware-example)


  2 Create a terraform.tfvars file based on Cloud Pak For data hardware resource requirement:
  
  ```
vsphere_server = "icovcpc65.rtp.raleigh.ibm.com"
ssh_user = "bob"
ssh_password = "res1dency$"
vsphere_datacenter = "IOCDCPC1"
vsphere_cluster = "ICO01"
vsphere_resource_pool = ""
datastore_cluster = "ICOPC1-SAN"
template = "rhel76tmpl-res"
folder = "res-test-cdoan"
hostname_prefix = "res-cdoan"
rhn_poolid = "8a85f99a6cbfea02016d017e15d51087"
private_network_label = "VIS241"
private_staticipblock = "9.46.68.0/24"
private_staticipblock_offset = 63
private_netmask = "24"
private_gateway = "9.46.68.1"
private_domain = "rtp.raleigh.ibm.com"
private_dns_servers = [ "9.42.106.2", "9.42.106.3" ]
master_cname = "cp4d-res-master.rtp.raleigh.ibm.com"
app_cname = "apps-cp4d-res.rtp.raleigh.ibm.com"
bastion = {
    nodes = "1"
    vcpu = "4"
    memory = "8192"
    disk_size = "100"
    docker_disk_size = "100"
    thin_provisioned = "true"
    keep_disk_on_remove = false
    eagerly_scrub = false
}
master = {
    nodes = "1"
    vcpu = "8"
    memory = "32768"
    disk_size = "100"
    docker_disk_size = "200"
    thin_provisioned = "true"
    keep_disk_on_remove = false
    eagerly_scrub = false
}
infra = {
    nodes = "1"
    vcpu = "8"
    memory = "32768"
    disk_size = "100"
    docker_disk_size = "200"
    thin_provisioned = "true"
    keep_disk_on_remove = false
    eagerly_scrub = false
}
worker = {
    nodes = "4"
    vcpu = "16"
    memory = "65536"
    disk_size = "100"
    docker_disk_size = "200"
    thin_provisioned = "true"
    keep_disk_on_remove = false
    eagerly_scrub = false
}
storage = {
    nodes = "3"
    vcpu = "4"
    memory = "16384"
    disk_size = "100"
    docker_disk_size = "100"
    gluster_disk_size = "1200"
    thin_provisioned = "true"
    keep_disk_on_remove = false
    eagerly_scrub = false
}
```

## Run terraform commands to deploy OCP.

   Run following commands in order:
   
     terraform init
     terraform plan
     terraform apply
