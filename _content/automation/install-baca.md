---
title: Install Business Automation Content Analyzer
weight: 400
---
- 
# make sure there is a space after the - so that the TOC is generated
{:toc}

### Required services
Before installing the IBM Business Automation Content Analyzer (BACA), you should have the following pre-requisites in place:

- Have privileged access to your DB2 database server. 
- Optionally, have access to your LDAP directory server.

See the [Shared services]({{ pages.github.url }}/CASE/cloudpak-onboard-residency/automation/shared-services) chapter for details on DB2 or LDAP installation, if needed.

### Log in to you OCP cluster
See the [Prerequisites]({{ pages.github.url }}/CASE/cloudpak-onboard-residency/automation/pre-requisites) chapter for details on logging in to your OCP cluster.

### Download the BACA PPA 
Download the following archive from [IBM Passport Advantage](https://www.ibm.com/software/passportadvantage) to your working directory:

- *IBM Cloud Pak for Automation v19.0.1 - Business Automation Content Analyzer for Certified Kubernetes Multiplatform Multilingual (CC224ML)*.

The downloaded archive should be named `ICP4A19.0.1-baca.tgz`.


### Create the BACA project

- Create a new OpenShift project for BACA with your desired name, e.g. `baca`:
```
oc new-project baca
```

- Make sure you are working from your newly created BACA project, then grant the tiller server edit access to current project:
```
oc project baca
oc adm policy add-role-to-user edit "system:serviceaccount:tiller:tiller"
```


### Push the BACA images to the registry

- Get the route to the docker service as described in the [Pre-requisites]({{ pages.github.url }}/CASE/cloudpak-onboard-residency/automation/pre-requisites.md) chapter, then login to your Docker registry:
```
docker login -u $(oc whoami) -p $(oc whoami -t) <route-to-docker-service>
```

- Download the `loadimages.sh` script from the `icp4a` GitHub repo to your working directory:
```
wget https://raw.githubusercontent.com/icp4a/cert-kubernetes/19.0.1/scripts/loadimages.sh
chmod +x loadimages.sh
```

- Load the BACA images (use `sudo` for on-prem cluster):
```
./loadimages.sh -p ICP4A19.0.1-baca.tgz -r <route-to-docker-service>
```

Note that BACA 19.0.1 consists of 17 images, so loading the images may take some time. 

### Create the BACA databases
The steps in this section should be performed on the server machine running your DB2 instance, under a DB2 privileged user login such as `db2inst1`.

#### Download the database creation scripts
- Log in to the server machine running your DB2 instance.

- From your working directory on this machine, run the following commands to download the BACA database creation scripts so they can be executed by a DB2 privileged user (e.g. `db2inst1`):
```
mkdir BACA_CREATE_DB
chmod a+w BACA_CREATE_DB
cd BACA_CREATE_DB
su db2inst1
git clone https://github.com/icp4a/cert-kubernetes.git
cd cert-kubernetes/BACA/configuration/DB2
```

#### Create the Base database
While logged in as `db2inst1`, run the following command to create the BACA Base database:

```
./CreateBaseDB.sh
```

The script will ask you to enter the following details:

- Name of the BACA Base database: use e.g. `CABASEDB`.
- Name of the database user: use e.g. `bacaadmin`.
- Password for the user: use e.g. `bacaadmin` each time when prompted. If it is an existing user, the prompt is skipped.

Enter `Y` when you are asked `Would you like to continue (Y/N)`.

#### Create the Tenant database
An initial user is created when creating the tenant database. If you are using LDAP for authentication, the name of this initial user must match the name of a user entry in LDAP (see [this section](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.install/k8s_topics/tsk_prepare_bacak8s_usergroups.html) of the IBM Knowledge Center for more information).

In the rest of this chapter, we choose to use LDAP and assume that a user named `bacauser` has been created in your LDAP directory. If LDAP is not used for authentication, the set-up of this user is not required. 

While logged in as `db2inst1`, run the following command to create the BACA Tenant database (see [this section](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.install/k8s_topics/tsk_prepare_bacak8s_db.html) of the IBM Knowledge Center for more details):

```
./AddTenant.sh
```

The script will ask you to enter the following details:

- Tenant ID: use e.g. `cp4a`
- Tenant type: use e.g. `0`
- BACA tenant database: use e.g. `TENANTDB`
- Host name or IP address of the database server: use your DB2 server IP
- Port of the database server: `50000`
- Do you want this script to create a database user: `y`
- Name of database user: use e.g. `bacauser`
- Password for the user: use e.g. `bacauser`, each time when prompted
- Tenant ontology name: Press Enter to accept the default
- Name of the Base BACA database: use e.g. `CABASEDB` (the name you provided when running the `CreateBaseDB.sh` script).
- Name of the database user for the Base database: use e.g. `bacaadmin` (the name you provided when running the `CreateBaseDB.sh` script)
- Company name: use e.g. `IBM`
- First name: use e.g. `baca`
- Last name: use e.g. `user`
- Valid email address: your email address
- Login name: use e.g. `bacauser`

Enter `Y` when you are asked `Would you like to continue (Y/N)`.

#### Clean up
Once the above scripts have been run successfully, you can delete the `BACA_CREATE_DB` directory.

### Set up the persistent volumes

Follow instructions at [Configuring storage for the Business Automation Content Analyzer environment](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.install/k8s_topics/tsk_prepare_bacak8s_storage.html) to create persistent volumes (PVs) and persistent volume claims (PVCs) and the associated directories.

You can use the [`baca-pv.yaml`]({{ site.github.url }}/assets/automation/baca/baca-pv.yaml) sample configuration file to create the PVs and PVCs for NFS. First, edit the file and update the `namespace`, NFS `path` and NFS `server` variable to match your environment, then run the command:

```
oc apply -f baca-pv.yaml -n baca
```

### Create secrets

In the working directory of your boot node, clone the `icp4a/cert-kubernetes` GitHub repo, then change to the BACA configuration scripts directory:

```
git clone https://github.com/icp4a/cert-kubernetes.git
cd cert-kubernetes/BACA/configuration
```

#### Configure common variables

The `init_deployments.sh` script requires you to populate parameters in `common.sh` file. 
Information on defining the parameters value can be found in [this section](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.ref/topics/ref_baca_common_params.html) of the IBM Knowledge Center.

You can use this [`common.sh`]({{ site.github.url }}/assets/automation/baca/common.sh) sample as a template. Note that:

- The `BASE_DB_PWD` and `LDAP_PASSWORD` passwords need to be encrypted with Base64.
- The value of `PVCCHOICE` is `2` since we already created the PVs and PVCs in an earlier step.
- The value of `HELM_INIT_BEFORE` is `y` since Helm has already been installed earlier.
- The `CA_WORKERS`, `MONGO_WORKERS` and `MONGO_ADMIN_WORKERS` variable should use the node names, not their IP addresses.
- The `BXDOMAINNAME` variable should be set to the public IP address of one of the nodes.

#### If you use managed OCP...

The `init_deployments.sh` script uses `loginToCluster` function in `bashfunctions.sh` to log into OpenShift cluster. This function assumes that Kubernetes API server is exposed on port `8443` and also requires user id and password to log into the cluster.

If you are using a Managed OpenShift cluster on IBM Cloud, this assumption is not valid, so you will have to modify the function to use login command copied from the OpenShift web console (available from the drop-down in the upper right corner of the OpenShift web console).

#### Run secrets creation
- Make sure your current project is `baca` and run the following command:
```
./init_deployments.sh
````

- Validate the objects created by running the following command:
```
oc get secrets
```
You should see 9 secrets were created (7 if not using LDAP or ingress):
```
NAME                       TYPE                                  DATA      AGE
baca-basedb                Opaque                                1         57s
baca-ingress-secret        kubernetes.io/tls                     2         1m
baca-ldap                  Opaque                                1         57s
baca-minio                 Opaque                                2         46s
baca-mongo                 Opaque                                3         58s
baca-mongo-admin           Opaque                                3         59s
baca-rabbitmq              Opaque                                4         46s
baca-redis                 Opaque                                1         45s
baca-secretsbaca           Opaque                                14        59s
```

### Install the BACA components

- Install the `bc` application if it is not available, as it is needed to execute the `generateMemoryValues.sh` script:
```
yum install bc
``

- Run the `generateMemoryValues.sh` script using the `limited` or `distributed`. For smaller system (5 worker-nodes or less) where the Mongo database pods will be on the same worker node as other pods, use `limited` option. See [this section](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.install/topics/tsk_preparing_baca_deploy_limitram.html) of the IBM Knowledge Center for more information.
```
./generateMemoryValues.sh limited
```

- From your working directory, run the following commands:
```
cd cert-kubernetes/BACA/helm-charts
tar xvf ibm-dba-baca-prod-1.0.0.tgz
cd ibm-dba-baca-prod
```

- Edit the `values.yaml` file to populate the configuration parameters (see [this page](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.ref/topics/ref_baca_globaloptions_params.html) of the IBM Knowledge Center and [this document](https://github.com/icp4a/cert-kubernetes/blob/19.0.1/BACA/docs/values_yaml_parameters.md) for more information).

- To deploy BACA, run the following command from the `ibm-dba-baca-prod directory:
```
helm install . --name celerybaca -f values.yaml  --namespace baca --tiller-namespace tiller
```

Due to the configuration of the readiness probes, after the pods start, it may take up to 10 or more minutes before the pods enter a ready state (see [this document](https://github.com/icp4a/cert-kubernetes/blob/19.0.1/BACA/helm-charts/README.md) for more information).

### Post-install tasks
Once all the pods are running, complete the post deployments steps listed in [this document](https://github.com/icp4a/cert-kubernetes/blob/19.0.1/BACA/docs/post-deployment.md).
