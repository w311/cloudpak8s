---
title: Cloud Automation Manager installation
weight: 800
---
- 
{:toc}

This docuemnt describes the steps to do an offline installation of Cloud Automation Manager.

# Prerequisites

Install the
[CloudPak Common Services](https://pages.github.ibm.com/CASE/cloudpak-onboard-residency/ocp/CloudPak_Common_Services_Installation/)

# Detailed steps

1. Download Cloud Automation Manager (PPA) Archive file

   There are 3 different locations to download install package.

   - **[IBM Passport Advantage](https://www.ibm.com/software/passportadvantage/)** for customer.
   - **[Software Sellers Workplace](https://w3-03.ibm.com/software/xl/download/ticket.do)** for all IBMers.
   - Artifactory repository for developers

   To download latest PPA file from artifactory, run following command,
   >curl -H 'X-JFrog-Art-Api:<Artifactory API Key>' -O "https://na.artifactory.swg-devops.com/artifactory/orpheus-local-generic/ppa-package/icp-cam-x86_64-3.2.1.0.tar.gz"
   
   You can get \<Artifactory API Key\> by clicking your login name on the right-upper corner of web page after logging into artifactory.

2. Download and configure the `Helm` and `Cloudctl` client binaries.

Using a browser, login to your MCM web console. On the welcome page, the upper right corner, click on the user icon and a menu displays. One of the options is `Configre client`, select it and the dialog displays. In the prerequisites section, click the link `Install CLI tools` and the instructions display. Following instructions to download the IBM Cloud Private CLI, the Kubernetes CLI, and the Helm CLI.

After the helm client distribution file is downloaded, move the helm distribution file to `/usr/local/bin/helm`

3. Connect to OCP and Docker

```
oc login -u <openshift console admin user> -p <openshift console admin password> --server=<OCP host server>
   or
oc login --token=<OCP token id>  --server=<OCP host server>

cloudctl login -a <icp console url> --skip-ssl-validation --u <mcm_cluster_administrator_id> -p <mcm_cluster_administrator_password> -n services

docker login -u $(oc whoami) -p $(oc whoami -t) <docker registry>
```

3. Gather the cluster information.

Get the existing StorageClass definitions as some pods need persistent storage.

```
oc get sc

NAME                          PROVISIONER         AGE
default                       ibm.io/ibmc-file    1d
ibmc-block-bronze (default)   ibm.io/ibmc-block   1d
ibmc-block-custom             ibm.io/ibmc-block   1d
ibmc-block-gold               ibm.io/ibmc-block   1d
ibmc-block-retain-bronze      ibm.io/ibmc-block   1d
ibmc-block-retain-custom      ibm.io/ibmc-block   1d
ibmc-block-retain-gold        ibm.io/ibmc-block   1d
ibmc-block-retain-silver      ibm.io/ibmc-block   1d
ibmc-block-silver             ibm.io/ibmc-block   1d
ibmc-file-bronze              ibm.io/ibmc-file    1d
ibmc-file-custom              ibm.io/ibmc-file    1d
ibmc-file-gold                ibm.io/ibmc-file    1d
ibmc-file-retain-bronze       ibm.io/ibmc-file    1d
ibmc-file-retain-custom       ibm.io/ibmc-file    1d
ibmc-file-retain-gold         ibm.io/ibmc-file    1d
ibmc-file-retain-silver       ibm.io/ibmc-file    1d
ibmc-file-silver              ibm.io/ibmc-file    1d
```
Check that ther is a `services` project.

```
oc get ns services
NAME       STATUS    AGE
services   Active    23h
```

Check that the 'ibm-anyuid-hostpath-scc' `SecurityContextConstraint` is defined for the kube-system project.

```
[root@icpclient01 downloads]# kubectl -n kube-system get scc ibm-anyuid-hostpath-scc
NAME                      PRIV    CAPS                                                                                                                    SELINUX    RUNASUSER   FSGROUP    SUPGROUP   PRIORITY   READONLYROOTFS   VOLUMES
ibm-anyuid-hostpath-scc   false   [SETPCAP AUDIT_WRITE CHOWN NET_RAW DAC_OVERRIDE FOWNER FSETID KILL SETUID SETGID NET_BIND_SERVICE SYS_CHROOT SETFCAP]   RunAsAny   RunAsAny    RunAsAny   RunAsAny   <none>     false            [*]
Collapse
```

4. Create a yaml file for SCC rolebinding

   Go to cluster folder and run the following:
   >mkdir resources && cd resources

   Create yaml file cam-scc-rolebinding.yaml.

   ```
   apiVersion: rbac.authorization.k8s.io/v1
   kind: ClusterRole
   metadata:
     name: ibm-anyuid-hostpath-scc-clusterrole
   rules:
   - apiGroups:
     - security.openshift.io
     resourceNames:
     - ibm-anyuid-hostpath-scc
     resources:
     - securitycontextconstraints
     verbs:
     - use
   ---
   apiVersion: rbac.authorization.k8s.io/v1
   kind: ClusterRoleBinding
   metadata:
     name: ibm-anyuid-hostpath-scc-clusterrolebinding
   roleRef:
     apiGroup: rbac.authorization.k8s.io
     kind: ClusterRole
     name: ibm-anyuid-hostpath-scc-clusterrole
   subjects:
   - apiGroup: rbac.authorization.k8s.io
     kind: Group
     name: system:serviceaccounts:services
   - kind: ServiceAccount
     name: default
     namespace: services
   ```

5. Create service ID, policy and APIKey

   Run following commands.

   ```
   export serviceIDName='service-deploy'
   export serviceApiKeyName='service-deploy-api-key'
   cloudctl login -a <Common Services Console URL> --skip-ssl-validation --u <Common Services User Name> -p <Common Services Password> -n services
   cloudctl iam service-id-create ${serviceIDName} -d 'Service ID for service-deploy'
   cloudctl iam service-policy-create ${serviceIDName} -r Administrator,ClusterAdministrator --service-name 'idmgmt'
   cloudctl iam service-policy-create ${serviceIDName} -r Administrator,ClusterAdministrator --service-name 'identity'
   cloudctl iam service-api-key-create ${serviceApiKeyName} ${serviceIDName} -d 'Api key for service-deploy'
   ```

   \<Common Services Console URL\> can be determined when installing Common Services. 
   
   You can also get the information by running `oc -n kube-system get route icp-console`.
   
   Replace \<Common Services User Name> and \<Common Services Password> with your instance values.

   The following is sample output. 

   ```
export serviceIDName='service-deploy'
export serviceApiKeyName='service-deploy-api-key'
oc login --token=dIZo-wIv4HSH4pw5EDZN7WHABlKZogVizrNdQJKFnns --server=https://c100-e.us-east.containers.cloud.ibm.com:32653 -n services
cloudctl iam service-id-create ${serviceIDName} -d 'Service ID for service-deploy'
Name          service-deploy
Description   Service ID for service-deploy
CRN           crn:v1:icp:private:iam-identity:mycluster:n/default::serviceid:ServiceId-0936e40d-c78d-43d7-aeaf-a0b23e56e510
Bound To      crn:v1:icp:private:k8:mycluster:n/default:::
cloudctl iam service-policy-create ${serviceIDName} -r Administrator,ClusterAdministrator --service-name 'idmgmt'
Creating policy for service ID service-deploy in namespace default as admin...
OK
Service policy is successfully created
Policy ID:   8cc7046b-383a-4022-9ed3-02afa5884857
Roles:       Administrator, ClusterAdministrator
Resources:
             Service Name   idmgmt
cloudctl iam service-policy-create ${serviceIDName} -r Administrator,ClusterAdministrator --service-name 'identity'
Creating policy for service ID service-deploy in namespace default as admin...
OK
Service policy is successfully created
Policy ID:   accabbba-3fd5-41f1-a10a-fe8a884491a2
Roles:       Administrator, ClusterAdministrator
Resources:
             Service Name   identity
cloudctl iam service-api-key-create ${serviceApiKeyName} ${serviceIDName} -d 'Api key for service-deploy'
Creating API key service-deploy-api-key of service service-deploy as admin...
OK
Service API key service-deploy-api-key is created
Please preserve the API key! It cannot be retrieved after it's created.
Name          service-deploy-api-key
Description   Api key for service-deploy
Bound To      crn:v1:icp:private:iam-identity:mycluster:n/default::serviceid:ServiceId-0936e40d-c78d-43d7-aeaf-a0b23e56e510
Created At    2019-09-05T20:02+0000
API Key       xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   ```

   Save the `ApiKey` for use in the next steps

   This yaml is used to append to the original common services deployment configuration

5. **Update config.yaml**

   Edit the config.yaml file and add following lines.
   
   NOTE: If using IBM storage, ensure that the **mongo PV** uses a storage class with a high IOPS specification (10 IOPS) - see chart
   
   ![Graphic]({{ site.github.url }}/assets/img/cp4mcm/storage_iops.png)

```
archive_addons:
    cam:
        namespace: services ## target namespace
        repo: local-charts  ## local helm chart repository.
        path: icp-cam-x86_64-3.2.1.0.tar.gz # the PPA file path relative to cluster dir
        charts:
        - name: ibm-cam  # chart name
          values:          # all values here will be passed onto helm when installing chart
            icp:
              port: 443
            managementConsole:
              port: 30000   # It is the default value. It will be used for UI URL.
            global:
              audit: false
              offline: true
              enableFIPS: false
              iam:
                  deployApiKey: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"  ## this is the value created by step 4 above.
            camMongoPV:
                name: "cam-mongo-pv"
                persistence:
                    enabled: true
                    useDynamicProvisioning: true
                    existingClaimName: ""
                    storageClassName: "ibmc-file-gold" # Use a file system storage class from the previously run 'oc get sc' 
                    accessMode: ReadWriteMany
                    size: 15Gi
             camLogsPV:
                name: "cam-logs-pv"
                persistence:
                    enabled: true
                    useDynamicProvisioning: true
                    existingClaimName: ""
                    storageClassName: "ibmc-file-bronze" # Use a file system storage class from the previously run 'oc get sc'
                    accessMode: ReadWriteMany
                    size: 10Gi
             camTerraformPV:
                name: "cam-terraform-pv"
                persistence:
                    enabled: true
                    useDynamicProvisioning: true
                    existingClaimName: ""
                    storageClassName: "ibmc-file-bronze" # Use a file system storage class from the previously run 'oc get sc'
                    accessMode: ReadWriteMany
                    size: 15Gi
             camBPDAppDataPV:
                name: "cam-bpd-appdata-pv"
                persistence:
                    enabled: true
                    useDynamicProvisioning: true
                    existingClaimName: ""
                    storageClassName: "ibmc-file-bronze" # Use a file system storage class from the previously run 'oc get sc'
                    accessMode: ReadWriteMany
                    size: 15Gi
```
   *NOTE: Please read inline comments*

6. **Copy package into cluster folder**

   Copy the package downloaded in step 1 into the cluster folder. If you want it to be placed elsewhere, you will need to update the 'path' variable in the config.yaml file accordingly.

7. **Run the inception installer**

   Go back to cluster folder and excute the following command
   >docker run -t --net=host -e LICENSE=accept -v $(pwd):/installer/cluster:z -v /var/run:/var/run:z -v /etc/docker:/etc/docker:z --security-opt label:disable ibmcom/icp-inception-amd64:3.2.1-rhel-ee addon

8. **Access CAM Web Console**

   After installing successfully, access web console using `https://<ICP Proxy Host>:<CAM Port number>`  . Logging in using Common Services credential.
   - \<ICP Proxy Host> can be got using `oc -n kube-system get routes`
   - Default CAM Port number is 30000

# Post installation storage permission issue 
If using IBM storage, the following fix has been documented on the knowledge center 
[Troubleshooting CAM issues](https://www.ibm.com/support/knowledgecenter/en/SS2L37_3.2.1.0/ts_cam_install_roks.html)

This fix describes updating the cam-bpd-mariadb, cam-provider-terraform, cam-proxy, and cam-bpd-ui deployments, but in addition, the following needs to be added to the cam-mango deployment

Run the following and add the information below. 
>kubectl edit deployment -n services cam-mongo

```
      imagePullSecrets:
      - name: xxxxxxx
      initContainers:
      - args:
        - chown 1000:1000 /data/db;
        command:
        - /bin/sh
        - -c
        image: alpine:latest
        imagePullPolicy: Always
        name: initcontainer
        resources: {}
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            add:
            - CHOWN
            - FOWNER
            - DAC_OVERRIDE
            drop:
            - ALL
          privileged: false
          readOnlyRootFilesystem: false
          runAsNonRoot: false
          runAsUser: 0
          seLinuxOptions:
            type: spc_t
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /data/db
          name: cam-mongo-pv
```
