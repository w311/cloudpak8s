## Openshift 3.11 Terraform-based installation on vSphere

To install OpenShift 3.11 on VMware using Terraform, you need the following:

- Terraform 0.12.x installation 
- VMware vSphere with API access 
- RedHat Network subscription for OpenShift
- Sizing information for the cluster
- DNS, subnet, gateway and available IPs for all cluster nodes

The first thing to install OpenShift 3.11 on a VMware information is to load the GIT repo for the VMware example:

```bash
git clone https://github.com/ibm-cloud-architecture/terraform-openshift3-vmware-example
```

The files that you get from the GIT repo are:

- `variables.tf`
- `main.tf`
- `infrastructure.tf`
- `loadbalancer.tf`
- `dns.tf`
- `certs.tf`
- `output.tf`

In the deployment, you must configure and review each of the `.tf` files for your infrastructure, and create and configure a `terraform.tfvars`.  We have attempted to separate them by the concerns in the filename.

Each `*.tf` contains modules that can be invoked for the deployment that you may not needed depending on your configuration.  For example, if high-availability is not required, the `loadbalancer.tf` file can be deleted and related variables can be removed from the other files.

One thing that you should do is to decide on how you want to manage your DNS. Whether you are using CloudFlare with LetsEncrypt, an RFC2136 compliant Dynamic DNS, nip.io or others. If you choose others, then it is very advisable to perform the `/etc/hosts` file customization to ensure that all nodes are recognized properly.

### Configuring Terraform

#### Accessing vSphere

Operation with the VMware infratructure is performed through the vSphere API. This section of the variables represents the resources that exists in the vSphere and must be identified to create the infrastructure. The snippet is below.

```
#######################################
##### vSphere Access Credentials ######
#######################################
vsphere_server = "vsphere-server.my-domain.com"

# Set username/password as environment variables VSPHERE_USER and VSPHERE_PASSWORD

##############################################
##### vSphere deployment specifications ######
##############################################
# Following resources must exist in vSphere
vsphere_datacenter = "CSPLAB"
vsphere_cluster = "Sandbox"
vsphere_resource_pool = "test-pool"
datastore_cluster = "SANDBOX_TIER4"
```

In the resources view, these are the vsphere hierarchy that must be identified to create the VM: 

![vsphere resource]({{ site.github.url }}/assets/ocp/vsphere_resources.png)

The disk images for VMs are stored in either a Datastore or in a larger environments, a Datastore cluster. You can specify either of this, but not both, the example above is using the `datastore_cluster` the option is using the `datastore` option. Go to the datastore tab and the following is the illustration: 
  
![datastore]({{ site.github.url }}/assets/ocp/vsphere_datastore.png)

Note that these names are case sensitive.

#### vSphere storage class information

These values specify the vSphere username and password to access the datastore.  When Openshift is installed, a storageclass named `vsphere-standard` will be used to create block volumes on the datastore specified using the vSphere user and password.

```
# for the vsphere-standard storage class
vsphere_storage_username = "<storageuser>"
vsphere_storage_password = "<storagepassword>"
vsphere_storage_datastore = "ds01"
```

Please see the following [link](https://vmware.github.io/vsphere-storage-for-kubernetes/documentation/vcp-roles.html) for the required permissions needed to by the storage user.


#### Template 

This information is needed also from the vSphere. OpenShift requires RedHat Enterprise Linux 7.4 or later VM template. You also should supply the credential to access the VMs that are created from the template. The credential can be using `ssh_user` and either one of `ssh_password` or `ssh_private_key_file`. The hostname prefix is used to prefix both the VM names and the hostname to be created in the DNS. Note that these names would have a random 8 hexadecimal characters to make sure that the hosts are unique.

```
template = "rhel-7.6-template"
# SSH username and private key to connect to VM template, has passwordless sudo access
ssh_user = "virtuser"
ssh_password = "<mypassword>"
ssh_private_key_file = "~/.ssh/id_rsa"

# MUST consist of only lower case alphanumeric characters and '-'
hostname_prefix = "ocp311"
```

Please see the following [link]({{ site.github.url }}/ocp/RHEL_template) for information about template preparation.

#### vSphere folder 

The folder defined should not exist as the installation will create them, this folder may be a path on which the last qualifier will be created. 

```
# vSphere Folder to provision the new VMs in, will be created
folder = "openshift311-folder"
```

#### Redhat account information

These are RedHat account to get either the RedHat Network subscription and getting the images for OpenShift. You can use the same username and password, but it is recommended that you create a RedHat service account for the image registry (see [these instructions](https://access.redhat.com/documentation/en-us/openshift_container_platform/3.11/html/configuring_clusters/install-config-configuring-red-hat-registry)). The RedHat subscription pool id can be retrieved from [this page](https://access.redhat.com/management/subscriptions?type=active) and select the subscription ID that you wanted to use.

```
# it's best to use a service account for these
image_registry_username = "<registry.redhat.io service account username>"
image_registry_password = "<registry.redhat.io service acocunt password>"

rhn_username = "<rhn username>"
rhn_password = "<rhn password>"
rhn_poolid = "<rhn pool id>"
```

#### Networking settings

Networking variables must be configured for the VMs. You may provide values for configuring both a private and public networks. see also ![network]({{ site.github.url }}/assets/ocp/network.png). 

The public network parameters are optional; if specified, it will place the bastion node on the public network.  In these scenarios you may want to stand up two load balancers on both the private and public networks to expose client traffic.

As a note, the example private network above would generate the first IP of `192.168.101.11` as the mask + offset + 1 gives you that address. You would need 4 addresses in the public network and the number of nodes + 1 for the private network. If you happen to have only a single flat network (ie the public and private network are the same network) then you would have to code the offset at least with a difference of 4.  

```
##### Network #####
private_network_label = "private_network"
private_staticipblock = "192.168.101.0/24"
private_staticipblock_offset = 10           # IP assignment starts at 192.168.101.11
private_netmask = "24"
private_gateway = "192.168.101.1"
private_domain = "internal-network.local"
private_dns_servers = [ "192.168.101.2" ]
```

Optionally, if you want to place the cluster on multiple networks, the cluster nodes where the pod overlay network is set up can be a completely private network, while the bastion host and load balancers can be placed on an external network.

```
public_network_label = "external_network"
public_staticipblock = "10.30.65.0/24"
public_staticipblock_offset = 30            # ips - [ 10.30.65.31, 10.30.65.32, 10.30.65.33 ]
public_netmask = "24"
public_gateway = "10.30.65.1"
public_domain = "my-public-domain.com"
public_dns_servers = [ "1.1.1.1" ]
```

This Terraform template also supports non-contiguous ip addresses. You can specify specific node IP addresses. In this example, the terraform will provision two worker nodes, at `.13` and `.14` while there will be 3 storage nodes, at `.15`, `.16`, `.17`. 

```
##### Network #####
private_network_label = "private_network"
bastion_private_ip = ["192.168.0.10"]
master_private_ip = ["192.168.0.11"]
infra_private_ip = ["192.168.0.12"]
worker_private_ip = ["192.168.0.13", "192.168.0.14"]
storage_private_ip = ["192.168.0.15", "192.168.0.16", "192.168.0.17"]

private_netmask = "24"
private_gateway = "192.168.0.1"
private_domain = "my-private-domain.local"
private_dns_servers = [ "192.168.0.1" ]
```

#### DNS settings

The `master_cname` and `app_cname` may be manually defined in the DNS for accessing the console and application routes, or added automatically using one of the DNS modules.  The `master_cname` is a CNAME record in DNS pointing at the master node or a load balancer distributing traffic to the master nodes.  The `app_cname` is a wildcard CNAME record in DNS pointing at the infra node or a load balancer distributing traffic to the infra nodes.

```
# these were added to my public DNS, the app_cname is a wildcard
master_cname = "ocp-console.my-public-domain.com"
app_cname = "ocp-apps.my-public-domain.com"
```

#### Nodes definition and sizing

this section defines the number of nodes for each kinds and how large is the vcpu, memory and disk sizes are. The disk size minimal is determined by the template, it must be the same or larger than the template that you start on. 

```
# node definitions
master = {
  nodes = "3"
  vcpu = "8"
  memory = "16384"

  disk_size = "100"
  docker_disk_size = "100"
  thin_provisioned = "true"
  keep_disk_on_remove = false
  eagerly_scrub = false
}

infra = {
  nodes = "3"
  vcpu = "8"
  memory = "32768"

  disk_size = "100"
  docker_disk_size = "100"
  thin_provisioned = "true"
  keep_disk_on_remove = false
  eagerly_scrub = false
}

worker = {
  nodes = "3"
  vcpu = "8"
  memory = "32768"

  disk_size = "100"
  docker_disk_size = "100"
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
  gluster_num_disks = "1"
  gluster_disk_size = "200"
  thin_provisioned = "true"
  keep_disk_on_remove = false
  eagerly_scrub = false
}
```

#### vSphere Credentials

Once you have all the variables customized, you also need to setup some environment variables to store your credentials:

- `VSPHERE_USER` and `VSPHERE_PASSWORD`: user ID and password to access the VMware vSphere environment

Use the following command:

```bash
export VSPHERE_USER=<user>
export VSPHERE_PASSWORD=<password>
```

### Provision the environment using Terraform

- Initialize Terraform environments (pulling in modules and plugins)

  ```bash
  terraform init
  ```

- use plan to see what terraform will do and validate the variables are correct:

  ```bash
  terraform plan
  ```

- Provision the environment

  ```bash
  terraform apply -auto-approve
  ```

The result should gives you the OpenShift 3.11 environment.

You should be able to access the environment using the URL of `https://ocp-console.<domain>` and logging in initially as `admin` with the password of `admin`.  Once additional set up of the environment is complete, you may want to configure a different identity provider for Openshift by following the [documentation](https://docs.openshift.com/container-platform/3.11/install_config/configuring_authentication.html).
