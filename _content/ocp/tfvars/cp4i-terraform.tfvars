vsphere_server = <VSphere server address>
ssh_user = <userid from the template>
ssh_password = <password for ssh_user>
vsphere_datacenter = <Datacenter name>
vsphere_cluster = <Cluster ID>
vsphere_resource_pool = ""
vsphere_storage_username = <user with access to storage>
vsphere_storage_password = <password to Vsphere storage>
vsphere_storage_datastore = "datastore1"

datastore_cluster = <Datastore Cluster name>
template = <VMware template name>
folder = <Vmware folder to be created>
hostname_prefix = <name prefix to each VM>
rhn_username = <RH username>
rhn_password = <RH password to subscription>
rhn_poolid = <RH subscription poolid>
image_registry_username = <user associated to the token from RH>
image_registry_password = <token from RH to download images>
private_network_label = <VSphere Network label>

private_netmask = "24"
private_gateway = <network Gateway>
private_domain = "my-cluster.com"
private_dns_servers = [ <list of DNS Servers> ]

master_cname = "cp4i-res-master.my-cluster.com"
app_cname = "apps-cp4i-res.my-cluster.com"

bastion_private_ip = ["192.168.102.211"]
master_private_ip = ["192.168.102.212"]
infra_private_ip = ["192.168.102.213"]
worker_private_ip = ["192.168.102.217", "192.168.102.218", "192.168.102.219", "192.168.102.220", "192.168.102.221", "192.168.102.222", "192.168.102.223"]
storage_private_ip = ["192.168.102.214", "192.168.102.215", "192.168.102.216"]

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
    nodes = "7"
    vcpu = "16"
    memory = "32768"
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
    gluster_disk_size = "1500"
    thin_provisioned = "true"
    keep_disk_on_remove = false
    eagerly_scrub = false
}