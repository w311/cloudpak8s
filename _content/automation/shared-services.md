---
title: Shared services
weight: 300
---
- 
# make sure there is a space after the - so that the TOC is generated
{:toc}

Most components from the IBM Cloud Pak for Automation need access to a database server and a directory service.
BACA and ECM specifically need access to a non-containerized DB2 database service.

The following sections provide instructions on how to install DB2 and the LDAP service provided by the IBM Security Directory Server.

## Install DB2

### Download the software archives
Download the following IBM DB2 v11.1 archives and fixpack in your working directory:
- *IBM DB2 Advanced Workgroup Server Edition Restricted Use Activation V11.1 for Linux, UNIX and Windows Multilingual* (CNB21ML).
- *IBM DB2 Advanced Workgroup Server Edition Server Restricted Use V11.1 for Linux on AMD64 and Intel EM64T systems (x64) Multilingual* (CNB8FML).
- [IBM DB2 11.1.x Universal Fixpack](https://www.ibm.com/support/pages/download-db2-fix-packs-version-db2-linux-unix-and-windows)

### Install the base DB2 version

- Install unzip if not present:
```
yum install unzip
```

- Download the DB2 response file [`db2dba.rsp`]({{ site.github.url }}/assets/automation/shared/db2dba.rsp) and edit the file to provide your password in the `<you-password>` placeholders.

- Expand the archive and start the install:
```
tar xzvf DB2_AWSE_REST_Svr_11.1_Lnx_86-64.tar.gz
unzip DB2_AWSE_Restricted_Activation_11.1.zip
./server_awse_o/db2setup -r db2dba.rsp
```
You will see the following warnings, which you can ignore.
```
Summary of prerequisites that are not met on the current system: 
DBT3514W  The db2prereqcheck utility failed to find the following 32-bit library file: "/lib/libpam.so*". 
DBT3514W  The db2prereqcheck utility failed to find the following 32-bit library file: "libstdc++.so.6". 
```

- Add the license
```
/opt/ibm/db2/V11.1/adm/db2licm -a awse_o/db2/license/db2awse_o.lic
```

### Install the fixpack
For more information, see for example [this page](https://www.ibm.com/support/knowledgecenter/en/SSBNJ7_1.4.3/db2/ttnpm_db2_FP1.html) of the IBM Knowledge Center.

```
## Expend the archive of the fixpack
tar xvf v11.1.4fp4a_linuxx64_universal_fixpack.tar.gz
## precheck before upgrade
cd universal
./db2prereqcheck -v 11.1.1.1 -i -s

## list all db2 instances
/opt/ibm/db2/V11.1/instance/db2ilist
db2inst1

## Stop the instance db2inst1
su - db2inst1
db2 list application
db2 force applications all
db2 terminate
db2stop force
db2licd -end
exit

ps -ef |grep db2fm
/opt/ibm/db2/V11.1/bin/db2fmcu -d
/opt/ibm/db2/V11.1/bin/db2fm -i db2inst1 -D

/opt/ibm/db2/V11.1/instance/db2iset -i db2inst1 -all
DB2_DEFERRED_PREPARE_SEMANTICS=YES
DB2_COMPATIBILITY_VECTOR=ORA
DB2COMM=TCPIP
DB2AUTOSTART=YES

/opt/ibm/db2/V11.1/instance/db2iauto -off db2inst1

su - db2inst1
ipclean
exit

su - dasusr1
/opt/ibm/db2/V11.1/das/bin/db2admin stop
exit

## Upgrade DB2
## In case go to the fixpack universal directory
cd /data/downloads/db2/fixpack11.1.1/universal
./installFixPack -b /opt/ibm/db2/V11.1

## Upgrade DB2 instance
/opt/ibm/db2/V11.1/instance/db2iupdt db2inst1
/opt/ibm/db2/V11.1/instance/db2iauto -on db2inst1
su - db2inst1
db2start
db2level
exit

#yum install libstdc++.so.6
#yum install libstdc++.so.5
#yum install compat-libstdc++-33
```

### Connection information
Upon install completion, you can test the install using the following connection information:

- URL: `<host>:50000`
- User: `db2inst1`
- Password: `<your-password>`


## Install LDAP

### Download the software archives
Download the following IBM Security Directory Server V6.4 archives and fixpack in your working directory:
- *IBM Security Directory Server Premium Feature Activation Package v6.4 Multiplatform Multilingual eAssembly (CRV3IML)*
- *IBM Security Directory Server V6.4 Client-Server ISO without entitlement for Linux x86-64 Multilingual (CN487ML)*

### Mount the SDS ISO
```
mkdir /mnt/iso
mount -t iso9660 -o loop /data/downloads/sds/sds64-linux-x86-64.iso /mnt/iso/
```

### Install SDS
```
yum install ksh

## Setup ldap user and group
groupadd idsldap
useradd -g idsldap -d /home/idsldap -m -s /bin/ksh idsldap
passwd idsldap
## enter '<your-password>'

usermod -a -G idsldap root
groups root

## Skip db2 installation
mkdir -p /opt/ibm/ldap/V6.4/install
touch /opt/ibm/ldap/V6.4/install/IBMLDAP_INSTALL_SKIPDB2REQ

## Install gskit
cd /mnt/iso/ibm_gskit
rpm -Uhv gsk*linux.x86_64.rpm

## Install sds rpms
cd /mnt/iso/license
./idsLicense
## Enter 1 to accept the license agreement

cd /mnt/iso/images
rpm --force -ihv idsldap*rpm

cd /data/downloads/sds
unzip sds64-premium-feature-act-pkg.zip
cd sdsV6.4/entitlement
rpm --force -ihv idsldap-ent64-6.4.0-0.x86_64.rpm

## Install ibm jdk
cd /mnt/iso/ibm_jdk
tar -xf 6.0.16.2-ISS-JAVA-LinuxX64-FP0002.tar -C /opt/ibm/ldap/V6.4/

## Setup db2 path
vi /opt/ibm/ldap/V6.4/etc/ldapdb.properties
currentDB2InstallPath=/opt/ibm/db2/V11.1
currentDB2Version=11.1.0.0

## Create and configure instance
cd /opt/ibm/ldap/V6.4/sbin
./idsadduser -u dsinst1 -g grinst1 -w <your-password>
## Enter 1 to continue

## Create instance
./idsicrt -I dsinst1 -p 389 -s 636 -e mysecretkey! -l /home/dsinst1 -G grinst1 -w <your-password>
## Enter 1 to continue

## Configure a database for a directory server instance.
./idscfgdb -I dsinst1 -a dsinst1 -w <your-password> -t dsinst1 -l /home/dsinst1

## Set the administration DN and administrative password for an instance
./idsdnpw -I dsinst1 –u cn=root –p <your-password>

## Add suffix
./idscfgsuf -I dsinst1 -s o=IBM,c=US
```

### Operating the SDS Server
```
## Start the directory server
./ibmslapd -I dsinst1

## Stop the directory server
./ibmslapd -I dsinst1 -k

## Start or stop the administration server
./ibmdiradm -I dsinst1

## Stop the administration server
./ibmdiradm -I dsinst1 -k

## Verify the server
cd /opt/ibm/ldap/V6.4/bin
./ldapsearch -h ldap://169.47.178.137:389 -s base -b " " objectclass=* ibm-slapdisconfigurationmode
```

### Import LDAP users and groups

- Install a tool such as [JXplorer](http://sourceforge.net/projects/jxplorer/files/jxplorer/version%203.3.1.2/jxplorer-3.3.1.2-windows-installer.exe/download) to browse your LDAP directory.
- Import the [`cp4a.ldif`]({{ site.github.url }}/assets/automation/shared/cp4a.ldif) LDAP Data Interchange Format file using this tool.

### Uninstall SDS
```
# Remove existing GSK
rpm -qa | grep -i gsk
rpm -e `rpm -qa | grep -i gsk`

# Remove all the other rpm
rpm -ev idsldap-srv64bit64-6.4.0-0.x86_64.rpm
rpm -qa | grep -i idsldap
rpm -ev `rpm -qa | grep -i idsldap`
```

### Connection information
Upon install completion, you can test the install using the following connection information:

- URL: `ldap://<host>:389`
- User: `cn=root`
- Password: `<your-password>`

