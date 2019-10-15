Openshift internally expects that all hostnames of cluster nodes are internally resolvable from each other.  


### Internal DNS names

For example, the following DNS setup may be used, where `cluster.jkwong.xyz` is the subdomain:

|node|names|comment|
|--|--|--|
|master1|`master01.cluster.jkwong.xyz`||
|master2|`master02.cluster.jkwong.xyz`||
|master3|`master03.cluster.jkwong.xyz`||
|infra1|`infra01.cluster.jkwong.xyz`||
|infra2|`infra02.cluster.jkwong.xyz`||
|infra3|`infra03.cluster.jkwong.xyz`||
|worker1|`worker01.cluster.jkwong.xyz`||
|worker2|`worker02.cluster.jkwong.xyz`||
|worker3|`worker03.cluster.jkwong.xyz`||
|internal API|`api-int.cluster.jkwong.xyz`|internal endpoint for API, used by cluster nodes to register|

The internal API endpoint should be an A or CNAME record that points at a load balancer that forwards requests to the master nodes running the control plane using a round-robin algorithm.  All cluster nodes will register themselves to the server to this endpoint using the domain name.  During installation, this may be provided as `openshift_master_cluster_hostname` in the ansible inventory file.

### External DNS names

It is optional whether the cluster administrator wishes to expose the internal cluster domain to an external DNS server, but in many cases the cluster domain is used here so worker nodes are fully resolvable outside of the cluster as well.

For external clients, Openshift expects that clients can resolve the hostname of the API server in order to manage Openshift, and application clients can resolve the hostname of the wildcard subdomain.

|node|name|comment|
|--|--|--|
|external API|`api.cluster.jkwong.xyz`|external endpoint for API, used by clients to manage Openshift|
|app|`*.apps.cluster.jkwong.xyz`|external wildcard domain for apps, used by clients to connect to workloads running in the platform such as Cloud Paks|

The Openshift application console is available on `api.cluster.jkwong.xyz` and is specified by `openshift_master_cluster_public_hostname`. It is very important to get this right as the web console uses the URL here as a redirect for OAuth clients and the address cannot be changed easily.  The DNS record points at an externally routable address to a load balancer that forwards traffic to the master nodes.

The wildcard app subdomain is a default domain name for routes that do not have an explicit hostname defined.  In our example, the Openshift cluster console is served at `console.apps.cluster.jkwong.xyz`.  The DNS record points at an externally routable address to a load balancer that forwards traffic to where the Openshift router is running, typically the `infra` nodes.
