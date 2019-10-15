---
title: Install FileNet Content Manager
weight: 700
---
- 
# make sure there is a space after the - so that the TOC is generated
{:toc}

### Required services
Before installing the IBM FileNet Content Manager (ECM), you should have the following pre-requisites in place:

- Have privileged access to your DB2 database server. 
- Optionally, have access to your LDAP directory server.

See the [Shared services]({{ pages.github.url }}/CASE/cloudpak-onboard-residency/automation/shared-services) chapter for details on DB2 or LDAP installation, if needed.

### Download the ECM PPA 
Download the following PPA from [IBM Passport Advantage](https://www.ibm.com/software/passportadvantage) to your working-directory:

-  *IBM Cloud Pak for Automation v19.0.1 - Content Manager for Certified Kubernetes Multiplatform Multilingual (CC220ML)* 

The downloaded archive should be named `ICP4A19.0.1-ecm.tgz`.

### Log in to you OCP cluster
See the [Prerequisites]({{ pages.github.url }}/CASE/cloudpak-onboard-residency/automation/pre-requisites) chapter for details on logging in to your OCP cluster.

### Create the ECM project
Create a new OpenShift project for ECM with your desired name, e.g. `ecmproject`:
```
oc new-project ecmproject
```
Make sure you are working from your newly created ECM project, then grant the tiller server `edit` access to current project:
```
oc project ecmproject
oc adm policy add-role-to-user edit "system:serviceaccount:tiller:tiller"
```

### Update the Security Context Constraint (SCC)
 - Add privileged access to default service account.  
 - The ecm Helm chart uses supplemental groups. You must modify the ecmproject namespace file to include that range of supplemental groups.  

```
oc adm policy add-scc-to-user privileged -z default

oc edit namespace ecmproject
```
While in the editor change this line:   
 - openshift.io/sa.scc.supplemental-groups: 1000250000/10000  
  
to the value 500/50000 so it looks like this:  
 - openshift.io/sa.scc.supplemental-groups: 500/50000  
  
If the SCC is not applied properly you may get the following error later on:
```
forbidden: unable to validate against any security context constraint: [fsGroup: Invalid value: []int64{50000}: 50000 is not an allowed group
```

### Push the ECM images to the registry
Login to the Docker registry using your correct docker registry url. Example below. If you are running on-premise (i.e. not OpenShift as Managed Service on IBM Cloud) then you may need to precede the docker command with `sudo`. If you are running on OpenShift as Managed Service on IBM Cloud you will need to turn on port forwarding as described in [Shared services](./shared-services.md) chapter. 

```
docker login -u $(oc whoami) -p $(oc whoami -t) docker-registry.default.svc:5000
```

Download the `loadimages.sh` script to your working directory:

```
wget https://raw.githubusercontent.com/icp4a/cert-kubernetes/19.0.1/scripts/loadimages.sh
chmod +x loadimages.sh
```

Load the ecm product binary images:

```
./loadimages.sh -p ICP4A19.0.1-ecm.tgz -r docker-registry.default.svc:5000/ecmproject
```

### Create the databases

Download these files to your working directory on the database server:
- [`GCDDB.sh`]({{site.github.url}}/assets/automation/cpe/db2/GCDDB.sh) 
- [`OS1DB.sh`]({{site.github.url}}/assets/automation/cpe/db2/OS1DB.sh) 

Run the following commands:

```
## copy the db2 install script
mkdir -p /data/db2fs
mkdir -p /data/database/config

## copy the GCDDB.sh and OS1DB.sh into folder /data/database/config
cp GCDDB.sh /data/database/config
cp OS1DB.sh /data/database/config

export CUR_COMMIT=ON
su - db2inst1 -c "db2set DB2_WORKLOAD=FILENET_CM"
echo "set CUR_COMMIT=$CUR_COMMIT"

chown db2inst1:db2iadm1 /data/database/config/*.sh
chmod 755 /data/database/config/*.sh
chown -R db2inst1:db2iadm1 /data/db2fs

## If you change the database names as the last entry on these lines you will also need to change them in GCD.xml and OBJSTORE.xml later on
su - db2inst1 -c "/data/database/config/GCDDB.sh GCDDB"
su - db2inst1 -c "/data/database/config/OS1DB.sh OS1DB"
```

### Set up the persistent volumes
Run the following commands to create the required PV folders in NFS, where `/data/persistentvolumes/` is the mounted directory of your NFS server:

```
mkdir -p /data/persistentvolumes/cpe/configDropins/overrides
mkdir -p /data/persistentvolumes/cpe/logs
mkdir -p /data/persistentvolumes/cpe/cpefnlogstore
mkdir -p /data/persistentvolumes/cpe/bootstrap
mkdir -p /data/persistentvolumes/cpe/textext
mkdir -p /data/persistentvolumes/cpe/icmrules
mkdir -p /data/persistentvolumes/cpe/asa

chown 50001:50000 /data/persistentvolumes/cpe/configDropins
chown 50001:50000 /data/persistentvolumes/cpe/configDropins/overrides
chown 50001:50000 /data/persistentvolumes/cpe/logs
chown 50001:50000 /data/persistentvolumes/cpe/cpefnlogstore
chown 50001:50000 /data/persistentvolumes/cpe/bootstrap
chown 50001:50000 /data/persistentvolumes/cpe/textext
chown 50001:50000 /data/persistentvolumes/cpe/icmrules
chown 50001:50000 /data/persistentvolumes/cpe/asa

mkdir -p /data/persistentvolumes/css/CSS_Server/data
mkdir -p /data/persistentvolumes/css/CSS_Server/temp
mkdir -p /data/persistentvolumes/css/CSS_Server/log
mkdir -p /data/persistentvolumes/css/CSS_Server/config
mkdir -p /data/persistentvolumes/css/indexareas

chown 50001:50000 /data/persistentvolumes/css/CSS_Server/data
chown 50001:50000 /data/persistentvolumes/css/CSS_Server/temp
chown 50001:50000 /data/persistentvolumes/css/CSS_Server/log
chown 50001:50000 /data/persistentvolumes/css/CSS_Server/config
chown 50001:50000 /data/persistentvolumes/css/indexareas

mkdir -p /data/persistentvolumes/cmis/configDropins/overrides
mkdir -p /data/persistentvolumes/cmis/logs

chown 50001:50000 /data/persistentvolumes/cmis/configDropins/overrides
chown 50001:50000 /data/persistentvolumes/cmis/logs
```

Obtain the DB2 drivers from your database server installation. Copy them to the PVs. If your database server is local the commands should look like this: 

```
cp /opt/ibm/db2/V11.1/java/db2jcc4.jar /data/persistentvolumes/cpe/configDropins/overrides/
cp /opt/ibm/db2/V11.1/java/db2jcc_license_cu.jar /data/persistentvolumes/cpe/configDropins/overrides/
```

Download all the cpe overrides files to your working directory 
 - [`GCD.xml`]({{site.github.url}}/assets/automation/cpe/configDropins/overrides/GCD.xml) 
 - [`OBJSTORE.xml`]({{site.github.url}}/assets/automation/cpe/configDropins/overrides/OBJSTORE.xml) 
 - [`DB2JCCDriver.xml`]({{site.github.url}}/assets/automation/cpe/configDropins/overrides/DB2JCCDriver.xml) 
 - [`ldap_TDS.xml`]({{site.github.url}}/assets/automation/cpe/configDropins/overrides/ldap_TDS.xml)  


If you changed the database names in the database creation step above, you will also need to change them in GCD.xml and OBJSTORE.xml here  

Edit GCD.xml, replacing `<ip-address>` with the ip-address of the database server, and possibly the database name.  
Edit OBJSTORE.xml, replacing `<ip-address>` with the ip-address of the database server, and possibly the database name.
DB2JCCDriver.xml contains the locations of the db2jcc4.jar and db2jcc_license_cu.jar files.  
Edit ldap_TDS.xml, replacing `<ip-address>` with the ip-address of the LDAP server.  

Then then run the following commands:

```
cp DB2JCCDriver.xml /data/persistentvolumes/cpe/configDropins/overrides/
cp GCD.xml /data/persistentvolumes/cpe/configDropins/overrides/
cp ldap_TDS.xml /data/persistentvolumes/cpe/configDropins/overrides/
cp OBJSTORE.xml /data/persistentvolumes/cpe/configDropins/overrides/
```
Download the cmis overrides files to your working directory. You may get a warning because the same filename is used by cpe.  

 - [`ldap_TDS.xml`]({{site.github.url}}/assets/automation/cmis/configDropins/overrides/ldap_TDS.xml)    
 
Edit ldap_TDS.xml, replacing `<ip-address>` with the ip-address of the LDAP server  
Then then run the following command:
```
cp ldap_TDS.xml /data/persistentvolumes/cmis/configDropins/overrides/
```

Download the [`cssSelfsignedServerStore`]({{site.github.url}}/assets/automation/css/cssSelfsignedServerStore) file to your working directory then run the following command:

```
cp cssSelfsignedServerStore /data/persistentvolumes/css/CSS_Server/data
```

Download the PV configuration files to your working directory.
 - [`cpe-pv.yaml`]({{site.github.url}}/assets/automation/cpe/cpe-pv.yaml)
 - [`css-pv.yaml`]({{site.github.url}}/assets/automation/css/css-pv.yaml)
 - [`cmis-pv.yaml`]({{site.github.url}}/assets/automation/cmis/cmis-pv.yaml) 

Edit each file. Replace the placeholder `<ip-address>` placeholder with the IP address of NFS server and adjust the persistent volume path if needed.

Run the following commands to create the PVs:

```
oc apply -f cpe-pv.yaml
oc apply -f css-pv.yaml
oc apply -f cmis-pv.yaml
```

### Create secrets
The Helm charts requires a secret in order to pull images from docker You might need to change the address of the docker server.
```
oc create secret docker-registry admin.registrykey --docker-server=docker-registry.default.svc:5000 --docker-username=$(oc whoami) --docker-password=$(oc whoami -t) -n ecmproject
```

Note that you cannot add the same secret more than once. If you need to delete a secret in order to create a new one, use the following command:  
```
oc delete secret admin.registrykey -n ecmproject
```

### Install the ECM components
Download these files to your working directory.
 - [`cpe-values.yaml`]({{site.github.url}}/assets/automation/cpe/cpe-values.yaml)
 - [`css-values.yaml`]({{site.github.url}}/assets/automation/css/css-values.yaml)
 - [`cmis-values.yaml`]({{site.github.url}}/assets/automation/cmis/cmis-values.yaml) 

Download the Helm charts to your working directory:

```
wget https://github.com/icp4a/cert-kubernetes/raw/master/CONTENT/helm-charts/ibm-dba-contentservices-3.0.0.tgz
wget https://github.com/icp4a/cert-kubernetes/raw/master/CONTENT/helm-charts/ibm-dba-contentsearch-3.0.0.tgz
wget https://github.com/icp4a/cert-kubernetes/raw/master/CONTENT/helm-charts/ibm-dba-cscmis-1.7.0.tgz
```
Install the Helm charts of CPE and Content Search:
```
helm install ibm-dba-contentservices-3.0.0.tgz --name cpe-prod-release --namespace ecmproject -f cpe-values.yaml
helm install ibm-dba-contentsearch-3.0.0.tgz --name css-prod-release --namespace ecmproject -f css-values.yaml
```

 - Expose the ACCE console service

Download the [`cpe-route.yaml`]({{site.github.url}}/assets/automation/cpe/cpe-route.yaml) file to your working directory and run the following command:
```
oc apply -f cpe-route.yaml
```
Find the URL of CPE web service using the command:
```
oc get routes
```

The URL should be something like: `http://cpe-prod-release-ibm-dba-contentservices-http-ecmproject.router.default.svc.cluster.local/wsi/FNCEWS40MTOM`

Edit the file cmis-values.yaml and change the attribute `cpeURL` then install the Helm chart of CMIS:
```
helm install ibm-dba-cscmis-1.7.0.tgz --name cmis-prod-release --namespace ecmproject -f cmis-values.yaml
```


### Open ACCE console in a browser

To retrieve the ACCE console service URL, first find the URL of the OCP cluster console:  

```
oc get route -n openshift-console

```

which will return something like this:

```
NAME      HOST/PORT                                   PATH      SERVICES   PORT      TERMINATION          WILDCARD
console   console.apps-cp4a-res.rtp.raleigh.ibm.com             console    https     reencrypt/Redirect   None
```

Open the Host/Port in a browser. Select the ecmproject. On the left, select Networking, and the routes. This will give you the base URL for ACCE. Append /acce to that url. That should take you to the ACCE page.

The user name is `ceadmin` and the password is `Passw0rd`.

### Post-install tasks

There is a set of steps you need to execute to complete the installation of CPE.

 - [Create the FileNet P8 domain](https://www.ibm.com/support/knowledgecenter/SSNW2F_5.5.0/com.ibm.p8.install.doc/p8pin328.htm)
 - [Create the database connection](https://www.ibm.com/support/knowledgecenter/SSNW2F_5.5.0/com.ibm.p8.install.doc/p8pin327.htm)
 - [Create an initial object store] (https://www.ibm.com/support/knowledgecenter/SSNW2F_5.5.0/com.ibm.p8.install.doc/p8pin034.htm)
 - [Install the necessary add-ons to the object store](https://www.ibm.com/support/knowledgecenter/en/SSNW2F_5.5.0/com.ibm.p8.ce.admin.tasks.doc/featureaddons/fa_install_addon.htm): This step can be done in the previous step while creating the object store. The following add-ons can be activated:
 ![Add-ons]({{ site.github.url }}/assets/automation/images/ObjectStoreAddOns.jpg)

 - [Configure CPE for Content Search Service](https://www.ibm.com/support/knowledgecenter/en/SSYHZ8_19.0.x/com.ibm.dba.install/k8s_topics/tsk_configcpe_css.html)
 
Here is the complete documentation for post-installation tasks:

- [Completing post-deployment tasks for IBM FileNet Content Manager](https://www.ibm.com/support/knowledgecenter/en/SSYHZ8_19.0.x/com.ibm.dba.install/k8s_topics/tsk_deploy_postecmdeployk8s.html)
- [Installation and Upgrade Worksheet](https://www.ibm.com/support/knowledgecenter/SSGLW6_5.5.0/com.ibm.p8toc.doc/p8_worksheet.xls)

### Uninstall
If needed, run the following steps to uninstall ECM:

```
helm delete cpe-prod-release --purge
helm delete css-prod-release --purge
helm delete cmis-prod-release --purge

# delete the cpe route
oc delete -f cpe-route.yaml
```

To delete the persisted data of the release, you can delete the PVCs using the following commands:

```
oc delete pvc cmis-cfgstore-pvc
oc delete pvc cmis-logstore-pvc
oc delete pvc cpe-bootstrap-pvc
oc delete pvc cpe-cfgstore-pvc
oc delete pvc cpe-filestore-pvc
oc delete pvc cpe-fnlogstore-pvc
oc delete pvc cpe-icmrules-pvc
oc delete pvc cpe-logstore-pvc
oc delete pvc cpe-textext-pvc
oc delete pvc cs-customstore-pvc
oc delete pvc css-cfgstore-pvc
oc delete pvc css-indexstore-pvc
oc delete pvc css-logstore-pvc
oc delete pvc css-tempstore-pvc

oc delete -f cpe-pv.yaml
oc delete -f css-pv.yaml
oc delete -f cmis-pv.yaml  
```

You can delete the Docker secret
```
oc delete secret admin.registrykey -n ecmproject
```

Ask your database administrator to delete the db2 instances.


### Troubleshooting

Check the pods for the ecmproject. This will show the overall health.

```
oc get pods -n ecmproject
```

Common problems:
 - The registry might have run out of space. 
 - Check that you're pulling from the docker registry that you uploaded to.
 - Review the security secret. 
 - Docker might be configured incorrectly.  
 

Make sure all five images were uploaded correctly. Check for errors in the `./loadimages.sh` step earlier.   

```
oc get imagestreams -n ecmproject
```

Use the oc describe pod to get a better idea of what failed:   

```
oc describe pod <pod name> -n ecmproject
```

Run oc logs to view the pod's log files

```
oc logs <pod name> -n ecmproject

```





