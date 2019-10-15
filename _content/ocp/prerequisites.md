---
title: Prerequisites
weight: 110
---

Openshift 3.x requires:

* [Red Hat Enterprise Linux 7](https://www.redhat.com/en/technologies/linux-platforms/enterprise-linux) subscription
* [Red Hat Openshift](https://www.redhat.com/en/technologies/cloud-computing/openshift) subscription
* [DNS]({{ site.github.url }}/ocp/prerequisites#setting-up-dns-requirements-for-openshift-deployment) - all cluster nodes require name resolution, and at least two records are required, one for the Openshift API, and a wildcard domain for all published applications. We have provided an example using Public DNS service from CloudFlare as an example.
* TLS certificates provided for both the API server and wildcard certificate for the default app subdomain used with the router.  For more information, see [Openshift documentation](https://docs.openshift.com/container-platform/3.11/install_config/certificate_customization.html).  If a custom certificate is not provided, self-signed certificates are generated.
* For HA, an external load balancer is required.  See this [documentation](https://github.com/redhat-cop/openshift-playbooks/blob/master/playbooks/installation/load_balancing.adoc) for more details.
* Shared Storage, either NFS or GlusterFS.  GlusterFS may be provisioned with Openshift 3.x as part of the [Openshift Container Storage](https://www.openshift.com/products/container-storage/) offering.

Depending on the cloud platform, you may require different infrastructure.  Review the [System Requirements](https://docs.openshift.com/container-platform/3.11/install/prerequisites.html) from the Openshift documentation.

Before following the rest of this documentation, it may be helpful to brush up on general Kubernetes knowledge.  IBM has published a tutorial [here](https://www.ibm.com/cloud/learn/kubernetes).

{% include_relative dns.md %}
