---
title: Install Business Automation Navigator
weight: 600
---
- 
# make sure there is a space after the - so that the TOC is generated
{:toc}

### Required services
Before installing IBM Business Automation Navigator (ICN), you should have the following pre-requisites in place:

- Have privileged access to your DB2 database server. 
- Optionally, have access to your LDAP directory server.

See the [Shared services]({{ pages.github.url }}/CASE/cloudpak-onboard-residency/automation/shared-services) chapter for details on DB2 or LDAP installation, if needed.

### Log in to you OCP cluster
See the [Prerequisites]({{ pages.github.url }}/CASE/cloudpak-onboard-residency/automation/pre-requisites) chapter for details on logging in to your OCP cluster.

### Download the ICN PPA 
Download the following PPA from [IBM Passport Advantage](https://www.ibm.com/software/passportadvantage) to your working-directory:

- *IBM Cloud Pak for Automation v19.0.1 - Content Navigator for Certified Kubernetes Multiplatform Multilingual (CC221ML)*

The downloaded archive should be named `ICP4A19.0.1-fncn.tgz`.

### Create the ICN project
Create a new OpenShift project for ICN with your desired name, e.g. `fncnproject`:

```
oc new-project fncnproject
```

Make sure you are working from  your newly created ICN project, then grant the tiller server `edit` access to current project:

```
oc project fncnproject
oc adm policy add-role-to-user edit "system:serviceaccount:tiller:tiller"
```

### Update the SCC
```
oc adm policy add-scc-to-user privileged -z default

oc edit namespace fncnproject
```

While in the editor change these lines:
 - openshift.io/sa.scc.supplemental-groups: 1000330000/10000
 - openshift.io/sa.scc.uid-range: 1000330000/10000  

To look like this:
 - openshift.io/sa.scc.supplemental-groups: 50000
 - openshift.io/sa.scc.uid-range: 50001

You may get the following error if the SCC is not applied properly:
```
forbidden: unable to validate against any security context constraint: [fsGroup: Invalid value: []int64{50000}: 50000 is not an allowed group
```

### Push the FNCN images to the registry
- Get the route to the docker service as described in the [Pre-requisites]({{ pages.github.url }}/CASE/cloudpak-onboard-residency/automation/pre-requisites.md) chapter, then login to your Docker registry:
```
docker login -u $(oc whoami) -p $(oc whoami -t) <route-to-docker-service>
```

- Download the `loadimages.sh` script from the `icp4a` GitHub repo to your working directory:
```
wget https://raw.githubusercontent.com/icp4a/cert-kubernetes/19.0.1/scripts/loadimages.sh
chmod +x loadimages.sh
```

- Load the ICN images (use `sudo` for on-prem cluster):
```
./loadimages.sh -p ICP4A19.0.1-fncn.tgz -r <route-to-docker-service>
```

### Create the database

Download [`createICNDB.sh`]({{site.github.url}}/assets/automation/icn/db2/createICNDB.sh), [`DB2_CREATE_SCRIPT.sql`]({{site.github.url}}/assets/automation/icn/db2/DB2_CREATE_SCRIPT.sql) and [`DB2_ONE_SCRIPT_ICNDB.sql`]({{site.github.url}}/assets/automation/icn/db2/DB2_ONE_SCRIPT_ICNDB.sql) to your working directory on the database server and run the following commands:
```
## copy the db2 install script
mkdir -p /data/db2fs
mkdir -p /data/database/config

## copy createICNDB.sh, DB2_CREATE_SCRIPT.sql and DB2_ONE_SCRIPT_ICNDB.sql files into folder /data/database/config
cp createICNDB.sh DB2_CREATE_SCRIPT.sql DB2_ONE_SCRIPT_ICNDB.sql /data/database/config

chown db2inst1:db2iadm1 /data/database/config
chown db2inst1:db2iadm1 /data/database/config/*.sh
chown db2inst1:db2iadm1 /data/database/config/*.sql
chmod 755 /data/database/config/*.sh

su - db2inst1
cd /data/database/config
./createICNDB.sh -n ICNDB -s ICNSCHEMA -t ICNTS -u db2inst1 -a ceadmin

## exit su mode
exit
```

### Set up the persistent volumes
Run the following commands to create the required PV folders in NFS, where `/data/persistentvolumes/` is the mounted directory of your NFS server:

```
mkdir -p /data/persistentvolumes/icn/configDropins/overrides
mkdir -p /data/persistentvolumes/icn/logs
mkdir -p /data/persistentvolumes/icn/plugins
mkdir -p /data/persistentvolumes/icn/viewerlog
mkdir -p /data/persistentvolumes/icn/viewercache
mkdir -p /data/persistentvolumes/icn/aspera

chown 50001:50000 /data/persistentvolumes/icn/configDropins/overrides
chown 50001:50000 /data/persistentvolumes/icn/logs
chown 50001:50000 /data/persistentvolumes/icn/plugins
chown 50001:50000 /data/persistentvolumes/icn/viewerlog
chown 50001:50000 /data/persistentvolumes/icn/viewercache
chown 50001:50000 /data/persistentvolumes/icn/aspera
```

Obtain the DB2 drivers from your database server installation. Copy them to the PVs. If your database server is local the commands should look like this: 

```
cp /opt/ibm/db2/V11.1/java/db2jcc4.jar /data/persistentvolumes/icn/configDropins/overrides/
cp /opt/ibm/db2/V11.1/java/db2jcc_license_cu.jar /data/persistentvolumes/icn/configDropins/overrides/
```

Download all the ICN overrides files to your working directory 
 - [`ICNDS.xml`]({{site.github.url}}/assets/automation/icn/configDropins/overrides/ICNDS.xml) 
 - [`DB2JCCDriver.xml`]({{site.github.url}}/assets/automation/icn/configDropins/overrides/DB2JCCDriver.xml) 
 - [`ldap_TDS.xml`]({{site.github.url}}/assets/automation/icn/configDropins/overrides/ldap_TDS.xml)  

If you changed the database name in the database creation step above, you will also need to change it in `ICNDS.xml` here  

Edit `ICNDS.xml`, replacing `<db-server-ip>` with the IP address of the database server, and possibly the database name.  
`DB2JCCDriver.xml` contains the locations of the `db2jcc4.jar` and `db2jcc_license_cu.jar` files.  
Edit `ldap_TDS.xml`, replacing `<ldap-server-ip>` with the IP address of the LDAP server.  

```
cp DB2JCCDriver.xml /data/persistentvolumes/icn/configDropins/overrides/
cp ICNDS.xml /data/persistentvolumes/icn/configDropins/overrides/
cp ldap_TDS.xml /data/persistentvolumes/icn/configDropins/overrides/
```

Download the [`pv.yaml`]({{site.github.url}}/assets/automation/icn/pv.yaml) configuration file to your working directory.

Replace the placeholder `<ip-address>` placeholder with the IP address of NFS server and adjust the persistent volume path if needed.

Run the following command to create the PVs:

```
oc apply -f pv.yaml
```

### Create secrets
The Helm chart requires a secret in order to pull images from docker. You might need to change the address of the docker server.

```
oc create secret docker-registry admin.registrykey --docker-server=docker-registry.default.svc:5000 --docker-username=$(oc whoami) --docker-password=$(oc whoami -t) -n fncnproject
```

Note that you cannot add the same secret more than once. If you need to delete a secret in order to create a new one, use the following command:  
```
oc delete secret admin.registrykey -n fncnproject
```

### Install the ICN components
- Download the [`values.yaml`]({{site.github.url}}/assets/automation/icn/values.yaml) file to your working directory.

- Download the Helm charts to your working directory:
```
wget https://github.com/icp4a/cert-kubernetes/raw/master/NAVIGATOR/helm-charts/ibm-dba-navigator-3.0.0.tgz
```

- Install the Helm charts:
```
helm install ibm-dba-navigator-3.0.0.tgz --name navigator-prod-release --namespace fncnproject -f values.yaml
```

### Expose the ICN console service
Download the [`route.yaml`]({{site.github.url}}/assets/automation/icn/route.yaml) file to your working directory and run the command:
```
oc apply -f route.yaml
```
To retrieve the ICN console service URL, open the `services` section on the OCP cluster console, select the desired ICN service, and go to the detail page to find the URL.

```
oc get route -n openshift-console

```

which will return something like this:

```
NAME      HOST/PORT                                   PATH      SERVICES   PORT      TERMINATION          WILDCARD
console   console.apps-cp4a-res.rtp.raleigh.ibm.com             console    https     reencrypt/Redirect   None
```

Open the Host/Port in a browser. Select the ecmproject. On the left, select Networking, and the routes. This will give you the base URL for ICN. Append `/navigator` to that URL. That should take you to the ICN page. The username is `ceadmin` and the password is `Passw0rd`.


### Post-install tasks

See the following step to complete the installation:
- [Configuring IBM Business Automation Navigator in a container environment](https://www.ibm.com/support/knowledgecenter/en/SSYHZ8_18.0.x/com.ibm.dba.install/k8s_topics/tsk_ecmconfigbank8s.html)

### Initialize your Navigator installation
Login to Navigator. Go to `Administration` panel from the `Main Menu`. Click on `Connections` then select the `Repositories` tab.

Create a repository: 
 - Choose `FileNet Content Manager repository` as type. 
 - The server URL must be your CPE service URL + `/wsi/FNCEWS40MTOM/`. This should look like: `https://cpe-prod-release-ibm-dba-contentservices-https-ecmproject.router.default.svc.cluster.local/wsi/FNCEWS40MTOM/`.
 - In the `Configuration Parameters` tab, set the `Entry template management` value to `Enabled`.
 
Create a `Desktop`.

### Uninstall
If needed, run the following steps to uninstall ICN:
```
helm delete navigator-prod-release --purge 
oc delete -f route.yaml
oc delete secret admin.registrykey -n fncnproject
```

To optionally delete the PVs
```
oc delete pvc icn-asperastore-pvc
oc delete pvc icn-cfgstore-pvc
oc delete pvc icn-logstore-pvc
oc delete pvc icn-pluginstore-pvc
oc delete pvc icn-vw-cachestore-pvc
oc delete pvc icn-vw-logstore-pvc

oc delete -f pv.yaml
```

Ask your database administrator to remove the databases associated with ICN.

### Troubleshooting

Check the pods for the ecmproject. This will show the overall health.

```
oc get pods -n fncnproject
```

 - Check for errors in the `./loadimages.sh` step earlier.  
 - The registry might have run out of room. 
 - Verify you're pushing/pulling to/from the right registry in the docker console.
 - Verify Secret is not preventing you from pulling images. 
 - Infrastructure might have evicted the registry pod.
 
Verify both images were uploaded and are available to your project workspace.

```
oc get imagestreams -n fncnproject
```

Run oc describe pod to gain insight into what's going on
```
oc describe pod <pod name> -n fncnproject

```

Run oc logs to view the pod's log files
```
oc logs <pod name> -n fncnproject

```



