---
title: Install Operational Decision Manager
weight: 800
---
- 
# make sure there is a space after the - so that the TOC is generated
{:toc}

### Required services
Before installing Operational Decision Manager (ODM), you should have the following pre-requisites in place:

- Have privileged access to your DB2 database server. 
- Optionally, have access to your LDAP directory server.

See the [Shared services]({{ pages.github.url }}/CASE/cloudpak-onboard-residency/automation/shared-services) chapter for details on DB2 or LDAP installation, if needed.

### Download the ODM PPA 
Download the following PPA from [IBM Passport Advantage](https://www.ibm.com/software/passportadvantage) to your working-directory:

- *IBM Cloud Pak for Automation v19.0.1 - Operational Decision Manager for Certified Kubernetes Multiplatform Multilingual (CC223ML)*

The downloaded archive should be named `ICP4A19.0.1-odm.tgz`.

### Log in to you OCP cluster
See the [Prerequisites]({{ pages.github.url }}/CASE/cloudpak-onboard-residency/automation/pre-requisites) chapter for details on logging in to your OCP cluster.

### Create the ODM project
- Create a new OpenShift project for ODM with your desired name, e.g. `odmproject`:
```
oc new-project odmproject
```
- Make sure you are working from your newly created ODM project, then grant the tiller server `edit` access to current project:
```
oc project odmproject
oc adm policy add-role-to-user edit "system:serviceaccount:tiller:tiller"
```

### Update the SCC
```
oc adm policy add-scc-to-user privileged -z default
```

### Push the ODM images to the registry
If you are installing ODM for the managed cloud, and you are logged in as root, do the following:
- Login to the Docker registry:
```
docker login -u $(oc whoami) -p $(oc whoami -t) docker-registry.default.svc:5000
```
- Download the `loadimages.sh` script to your working directory:
```
wget https://raw.githubusercontent.com/icp4a/cert-kubernetes/19.0.1/scripts/loadimages.sh
chmod +x loadimages.sh
```
- Load the images:
```
./loadimages.sh -p ICP4A19.0.1-odm.tgz -r docker-registry.default.svc:5000/odmproject
```
To complete above steps, make sure that the port forwarding is properly addressed, see the [Pre-requisites]({{ pages.github.url }}/CASE/cloudpak-onboard-residency/automation/pre-requisites) chapter for details on the docker registry port forwarding. Otherwise, you might not be able to login to the docker registry, or face timeout during the image push.

If you are installing ODM for on-prem OCP, and not logged in root, do the following:
- Login to the Docker registry:
```
oc -n default get route
# search for route to docker-registry
sudo docker login -u $(oc whoami) -p $(oc whoami -t) <route_to_docker_registry>
```
- Download the `loadimages.sh` script to your working directory:
```
wget https://raw.githubusercontent.com/icp4a/cert-kubernetes/19.0.1/scripts/loadimages.sh
chmod +x loadimages.sh
```
- Load the images:
```
sudo ./loadimages.sh -p ICP4A19.0.1-odm.tgz -r <route_to_docker_registry>/odmproject
```

### Create the ODM database
The below step is assumed that external DB2 database is used, if internal database or other types of external databases are used, please refer to the related product documentation.

Log in to the server machine running your DB2 instance, and run the following commands:
```
su - db2inst1
db2 create database odmdb automatic storage yes  using codeset UTF-8 territory US pagesize 32768;
db2 connect to odmdb
db2 list applications
```

### Create secrets

#### Create an LDAP secret
- Download the [`ldap-configurations.xml`]({{ site.github.url }}/assets/automation/odm/ldap-configurations.xml) and [`webSecurity.xml`]({{ site.github.url }}/assets/automation/odm/webSecurity.xml) files to your working directory.

- Update the `ldap-configurations.xml` and `webSecurity.xml` file to replace the ldap host with the public IP address of your LDAP server.

- If needed, you might also update the access info within `webSecurity.xml` file, e.g. to add additional user or group. For the details on how to configure the access info, please refer to the related [ODM knowledge center section](https://www.ibm.com/support/knowledgecenter/en/SSYHZ8_19.0.x/com.ibm.dba.install/k8s_topics/tsk_config_user_access.html).

- Run the following command:
```
oc create secret generic odm-prod-release-odm-ldap --from-file=ldap-configurations.xml --from-file=webSecurity.xml --type=Opaque
```

#### Create a BAI Event secret
If you plan to use BAI, download the [`plugin-configuration.properties`]({{ site.github.url }}/assets/automation/odm/plugin-configuration.properties) file to your working directory and make sure that your BAI Kafka server name is same as the one in `plugin-configuration.properties`, then run the following command:
```
oc create secret generic odm-prod-release-odm-bai-event --from-file=plugin-configuration.properties
```

### Install the ODM components
- Download the [values.yaml]({{ site.github.url }}/assets/automation/odm/values.yaml) file to your working directory and update the DB configuration parameters under `externalDatabase` to match your configuration, in particular the IP address for the `serverName` and the `password` for the DB admin account.

- Download the Helm chart to your working directory:
```
wget https://github.com/icp4a/cert-kubernetes/raw/19.0.1/ODM/helm-charts/ibm-odm-prod-2.2.0.tgz
```

- Install the Helm chart:
```
helm install ibm-odm-prod-2.2.0.tgz --name odm-prod-release --namespace odmproject -f values.yaml
```

### Expose the ODM services
Download the [route.yaml]({{ site.github.url }}/assets/automation/odm/route.yaml) file to your working directory and run the command:
```
oc create -f route.yaml
```

To retrieve the ODM services URLs, open the `services` section on the OCP cluster console, select the desired ODM service, such as `odm-decisioncenter` and go to the detail page to find the URL. The link will look like:
```
https://odm-prod-release-odm-decisioncenter-odmproject.cp4a-ocp-6550a99fb8cff23207ccecc2183787a9-0001.us-south.containers.appdomain.cloud/decisioncenter
```

### Uninstall
If needed, run the following steps to uninstall ODM:
```
helm delete odm-prod-release --purge
oc delete secret odm-prod-release-odm-ldap
oc delete secret odm-prod-release-odm-bai-event
oc delete -f route.yaml
```

Please note that if this Uninstall is permanent, you might want to clean the related DB2 tables that have been created. For this, please refer to the related [Shared services](./shared-services.md) section for details.
