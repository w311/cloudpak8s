## Creating RHEL VMware Template 

Before using the VMware terraform, the VSphere infrastructure must have a VM template available for the RHEL OS image.  This VMware template will be used to create each of the VMs for the OpenShift cluster nodes.

### Download RHEL 7.6 ISO
From your RedHat access account, download the RHEL 7.6 Boot ISO to your local machine.  Refer to [RedHat download documentation](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/installation_guide/chap-download-red-hat-enterprise-linux).

### Upload ISO to VSphere
From your local machine, connect to your VMware instance to upload the ISO to a datastore.  This will be used as the base of the template that gets created in the next step. Refer to [VMware ISO upload documentation](https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.vm_admin.doc/GUID-492D6904-7471-4D66-9555-9466CCCA6931.html).

Take note of what datastore and folder was chosen during the upload as it will be needed during the last step of "Create VMware template"

### Create a VMware Virtual Machine 
A VMware template is created from a runnable Virtual Machine. In this section, you'll create a new machine definition and install the basic operating system.

#### Create the Virtual Hardware definition
Define the virtual hardware settings for a new VM by using the guidance at VMware Docs topic 
[Create a Virtual Machine Without a Template or Clone](https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.vm_admin.doc/GUID-AE8AFBF1-75D1-4172-988C-378C35C9FAF2.html). Pay attention to these parameters (the author found these settings in Step 7, "Customizing Hardware", of the ESX 6.5 "New Virtual Machine" wizard)
- "Storage" set per your VSphere administrator.
- The CPU count, memory and disk sizes are usually modified by the deployment automation at a later point, so the initial values aren't critical.  Reasonable initial values are 2 CPU, 8 GB memory, and 100 GB disk.
- **IMPORTANT:** Select "Thin provisioning" for the hard disk definition. This selection can be set under "New Disk" > "Disk Provisioning". Thin provisioning provides for smaller initial resource allocation, while enabling future growth.
- "New network" - Select "Browse" to select value provided by your VSphere administrator.

Once the wizard completes, you will have a new VM definition, but the operating system still needs to be installed.

#### Install RHEL from the ISO image
After defining the virtual hardware specification, you need to install the guest OS. 

Reference the instructions at VMware Docs topic [Installing Guest Operating System](https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.vm_admin.doc/GUID-90E7F734-D699-4603-B222-AF4DE84459C7.html). The last option on this page describes how to "Install a Guest Operating System from Media". Use this guidance to install the OS from the ISO file that you uploaded in an earlier step. You can make the ISO image available to your VM definition by setting the CD/DVD drive to "Datastore / ISO Drive", then selecting the bootable ISO file that you uploaded. Be sure to also select that the drive should be "Connected".

The RHEL install process is part of the ISO image. Power on the newly created machine definition to launch the install from the .ISO image in the virtual CD-ROM/DVD drive. The following guidance may be useful when performing the install.
- Installation destination: "Automatic partitioning" works OK.
- Create one user (the author uses the name "admin"). Make this user an Administrator by selecting the appropriate checkbox on the "new user" creation panel in the wizard.

Select "Reboot" at the conclusion of the RHEL installation process.

### Add OpenShift prerequisites to the RHEL image
The basic RHEL operating system is now installed, but the RHEL repositories that support the OpenShift installation are not. The deployment automation that will be used later, also requires a user id for a user with administrative access. This section provides guidance for setting up setting up these prerequisites, as well as other general housekeeping that's appropriate when creating a template.

#### Add privileges to your 'admin' user
Add needed sudo privileges to your 'admin' user by adding one line to the "/etc/sudoers configuration file. The "visudo" utility is a vi-like editor that provides a measure of safety when editing this file. From a terminal prompt, issue:

``` md
visudo
```

Add the following line to the bottom of the file. If your admin user is named something other than 'admin', then substitute your admin user name for 'admin' in the line below:
``` md
admin ALL=(ALL) NOPASSWD: ALL
```

Save the changes, and exit.

#### Setup Red Hat subscription access and repos

Modify the following script for your specific credentials, then execute the script at a terminal prompt in your running VM. The `yum update` will ensure that RHEL has the latest updates installed.  This can take a bit of time to download the latest RPM packages, so be patient.

``` md
subscription-manager register --username=$rhn_username --password=$rhn_password
subscription-manager attach --pool=$rhn_poolid
yum update -y
subscription-manager repos --disable="*"
subscription-manager repos --enable="rhel-7-server-rpms" --enable="rhel-7-server-extras-rpms" --enable="rhel-7-server-ose-3.11-rpms" --enable="rhel-7-server-ansible-2.6-rpms" --enable="rhel-7-server-optional-rpms" --enable="rhel-7-fast-datapath-rpms" --enable="rh-gluster-3-client-for-rhel-7-server-rpms"
yum install -y perl wget vim-enhanced net-tools bind-utils tmux git iptables-services bridge-utils docker etcd rpcbind ansible bash-completion dnsmasq ntp logrotate httpd-tools bind-utils firewalld libselinux-python conntrack-tools openssl iproute python-dbus PyYAML yum-utils glusterfs-fuse device-mapper-multipath nfs-utils iscsi-initiator-utils ceph-common atomic cifs-utils samba-common samba-client

package-cleanup --oldkernels --count=1
yum clean all

subscription-manager remove --all
subscription-manager unregister
```

#### General housekeeping
The following script will do cleanup to make a smaller template and decrease VM deployment time. 

Execute the script from a terminal prompt in your running VM:

``` md
/sbin/service auditd stop
/sbin/service rsyslog stop

/usr/sbin/logrotate -f /etc/logrotate.conf
/bin/rm -f /var/log/*-???????? /var/log/*.gz
/bin/rm -f /var/log/dmesg.old
/bin/rm -rf /var/log/anaconda
/bin/cat /dev/null > /var/log/audit/audit.log
/bin/cat /dev/null > /var/log/wtmp
/bin/cat /dev/null > /var/log/lastlog
/bin/cat /dev/null > /var/log/grubby
/bin/rm -f /etc/udev/rules.d/70*
/bin/sed -i '/UUID/d' /etc/sysconfig/network-scripts/ifcfg-e*
/bin/sed -i '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-e*
/bin/rm -rf /tmp/*
/bin/rm -rf /var/tmp/*
/bin/rm -f /etc/ssh/*key*

/bin/rm -f ~root/.bash_history
unset HISTFILE
/bin/rm -rf ~root/.ssh/
/bin/rm -f ~root/anaconda-ks.cfg
history -c
sys-unconfig
```
Reference [Create a RHEL/CentOS 6/7 Template for VMware vSphere](https://community.spiceworks.com/how_to/151558-create-a-rhel-centos-6-7-template-for-vmware-vsphere) for an explanation of each of the steps in the script above.

### Convert to a Template
You'll convert the VM to a template in this final step. The template makes the machine reusable for the terraform automation. You can convert the machine to a template by selecting the machine, then selecting the "Template" action from any menu.

Take note of the folder location and name of template as this is needed in the setup variables for terraform deployment.
