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

master_cname = "cp4app-res-master.my-cluster.com"
app_cname = "apps-cp4app-res.my-cluster.com"

bastion_private_ip = ["192.168.104.211"]
master_private_ip = ["192.168.104.212"]
infra_private_ip = ["192.168.104.213"]
worker_private_ip = ["192.168.104.217", "192.168.104.218"]

storage_class = "vsphere-standard"

bastion = {
    nodes               = "1"
    vcpu                = "2"
    memory              = "8192"
    disk_size           = ""      # Specify size or leave empty to use same size as template.
    docker_disk_size    = "100"   # Specify size for docker disk, default 100.
    thin_provisioned    = ""      # True or false. Whether to use thin provisioning on the disk. Leave blank to use same as template
    eagerly_scrub       = ""      # True or false. If set to true disk space is zeroed out on VM creation. Leave blank to use same as template
    keep_disk_on_remove = "false" # Set to 'true' to not delete a disk on removal.
}

master = {
    nodes                 = "1"
    vcpu                  = "8"
    memory                = "32768"
    disk_size             = ""      # Specify size or leave empty to use same size as template.
    docker_disk_size      = "100"   # Specify size for docker disk, default 100.
    thin_provisioned      = ""      # True or false. Whether to use thin provisioning on the disk. Leave blank to use same as template
    eagerly_scrub         = ""      # True or false. If set to true disk space is zeroed out on VM creation. Leave blank to use same as template
    keep_disk_on_remove   = "false" # Set to 'true' to not delete a disk on removal.
}

infra = {
    nodes               = "1"
    vcpu                = "8"
    memory              = "32768"
    disk_size           = ""      # Specify size or leave empty to use same size as template.
    docker_disk_size    = "100"   # Specify size for docker disk, default 100.
    thin_provisioned    = ""      # True or false. Whether to use thin provisioning on the disk. Leave blank to use same as template
    eagerly_scrub       = ""      # True or false. If set to true disk space is zeroed out on VM creation. Leave blank to use same as template
    keep_disk_on_remove = "false" # Set to 'true' to not delete a disk on removal.
}

worker = {
    nodes               = "2"
    vcpu                = "8"
    memory              = "32768"
    disk_size           = ""      # Specify size or leave empty to use same size as template.
    docker_disk_size    = "100"   # Specify size for docker disk, default 100.
    thin_provisioned    = ""      # True or false. Whether to use thin provisioning on the disk. Leave blank to use same as template
    eagerly_scrub       = ""      # True or false. If set to true disk space is zeroed out on VM creation. Leave blank to use same as template
    keep_disk_on_remove = "false" # Set to 'true' to not delete a disk on removal.
}

storage = {
    nodes               = "0"
}