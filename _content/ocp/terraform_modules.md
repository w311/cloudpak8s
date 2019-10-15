
## Openshift Terraform Modules

Because Openshift is a complex system with multiple moving parts, we have created Terraform modules for things that are common across Openshift installation across cloud infrastructure.  We have organized these modules types into categories.

Depending on the infrastructure available at a particular client site, we may select different modules to use to stand up the full platform.

Using modules also allows us to begin the automation at any point in the provisioning process. For example, some clients may not give access to automate every part of the installation process; in these cases you may remove the corresponding module and provide manual inputs to the upper modules, or manually perform some operation and run just the modules that can just be automated.

We have an end-to-end example of installation of Openshift on VMware using these modules here: [terraform-openshift3-vmware-example](https://github.com/ibm-cloud-architecture/terraform-openshift3-vmware-example).

Another end-to-end example using IBM Cloud VPC infrastructure: [terraform-openshift3-ibmcloud-vpc-example](https://github.com/jkwong888/terraform-openshift3-ibmcloud-vpc-example).

### Infrastructure Modules

This category of modules creates a set of physical of virtual servers used to form the Openshift cluster.  As every Openshift cluster requires servers to host the platform, this forms the base building blocks of the cluster.  As each cloud provider uses a different Terraform provider, the expectation is at the end of these modules we will have a list of IP addresses and hostnames that we can run the Openshift installation across.

Some cloud providers require additional resources outside of just virtual servers; for example on AWS we may require a VPC, subnets, security groups, etc.

| provider | module github |
|----------|----|
| vmware   | [terraform-openshift3-infra-vmware](https://github.com/ibm-cloud-architecture/terraform-openshift3-infra-vmware) |
| ibmcloud (classic) | [terraform-openshift-infra-ibmcloud-classic](https://github.com/jkwong888/terraform-openshift-infra-ibmcloud-classic) |
| ibmcloud (vpc) | [terraform-openshift3-infra-ibmcloud-vpc](https://github.com/jkwong888/terraform-openshift3-infra-ibmcloud-vpc) |
| azure | [terraform-openshift-azure](https://github.com/ibm-cloud-architecture/terraform-openshift3-infra-azure) |
| aws | |
| gcp | |
| openstack | |
| user provided | [terraform-openshift-userprovidedinfra](https://github.com/ncolon/terraform-openshift-userprovidedinfra) |

### DNS modules

This category of modules creates records in a Domain Name Service system according to the cluster resources.  It should take as input a list of nodes and hostnames, and any other record types required for cluster execution, and create the records in DNS.

We also provide a "hack" DNS for internal cluster name resolution between all cluster nodes by generating an `/etc/hosts` file and synchronizing it to all cluster nodes.  Openshift requires both forward and reverse DNS which may not always be possible; `/etc/hosts` can sometimes satisfy these requirements.

* [terraform-dns-etc-hosts](https://github.com/ibm-cloud-architecture/terraform-dns-etc-hosts) - create a `/etc/hosts` file and sync across cluster nodes
* [terraform-dns-cloudflare](https://github.com/ibm-cloud-architecture/terraform-dns-cloudflare) - add records to CloudFlare
* [terraform-dns-rfc2136](https://github.com/ibm-cloud-architecture/terraform-dns-rfc2136) - add records according to RFC2136 dynamic DNS update.

Note that for the last DNS module, we provided a module that provisions a DNS server running bind on a RHEL VM, in scenarios where we do not have direct access to add DNS records:

* [terraform-dns-bind-rhel-vmware](https://github.com/jkwong/terraform-dns-bind-rhel-vmware)

### Load Balancer modules

This category of modules creates or programs a load balancer according to the cluster resources.  In Openshift, we require a load balancer when the cluster is configured with High Availability.

We also provide a "hack" load balancer module that provisions and configures an HAProxy instance on VMware as a stand-in for demos.

* [terraform-lb-haproxy-vmware](https://github.com/ibm-cloud-architecture/terraform-lb-haproxy-vmware)

### Certificate modules

This category of modules obtain TLS certificates from a Certificate Authority, for example for the control plane or a wildcard certificate for applications.

* [terraform-certs-letsencrypt-cloudflare](https://github.com/ibm-cloud-architecture/terraform-certs-letsencrypt-cloudflare) - Get certificate from LetsEncrypt with DNS01 challenge using CloudFlare

### Configuration modules

Run an ad-hoc script or ansible playbook across cluster nodes.  We prefer ansible to do configuration drift detection, as a complement to using Terraform to do infrastructure drift detection.

* [terraform-openshift-rhnregister](https://github.com/ibm-cloud-architecture/terraform-openshift-rhnregister) - register a set of nodes with Red Hat Network
* [terraform-openshift3-deploy](https://github.com/ibm-cloud-architecture/terraform-openshift3-deploy) - generate openshift inventory file and install openshift
