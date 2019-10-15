---
title: Cloud Application Management installation
weight: 850
---
- 
{:toc}

This docuemnt describes the steps to do an offline installation of the Cloud Application Management package.

# Prerequisites

Install the
[CloudPak Common Services](https://pages.github.ibm.com/CASE/cloudpak-onboard-residency/ocp/CloudPak_Common_Services_Installation/)

# Detailed steps

1. Download Cloud Application Management (PPA) Archive file

   There are 3 different locations to download install package.

   - **[IBM Passport Advantage](https://www.ibm.com/software/passportadvantage/)** for customer.
   - **[Software Sellers Workplace](https://w3-03.ibm.com/software/xl/download/ticket.do)** for all IBMers.
   - Artifactory repository for developers

   To download the latest PPA file from artifactory, run following command:
   ```
   curl -H 'X-JFrog-Art-Api:<Artifactory API Key>' -O "https://na.artifactory.swg-devops.com/artifactory/perfmgmt-helm-generic-local/ppa/incubator/ppa_\<Latest Timestamp\>_prod.tar.gz"
   ```
   
   You can get \<Artifactory API Key\> by clicking your login name on the upper right corner of web page after logging into artifactory.
   
   Move the ppa package to the 'cluster' folder.

2. Download and install the `Helm` and `Cloudctl` client binaries if not already installed.

Log into your MCM web console, and on the welcome page the `Install CLI tools` button is displayed. Click the button and follow the instructions to download and configure it. The `helm` client can be configured automatially after running `cloudctl login`.
```
https://icp-console.mcmresidency1-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud/console/tools/cli
```
3. Connect to OCP and Docker

Change to the cluster folder

```
export KUBECONFIG=<cluster folder>/kubeconfig
oc login -u <openshift console admin user> -p <openshift console admin password> --server=<OCP host server>
   or
oc login --token=<OCP token id>  --server=<OCP host server>

cloudctl login -a <icp console url> --skip-ssl-validation --u <mcm_cluster_administrator_id> -p <mcm_cluster_administrator_password> -n services

docker login -u $(oc whoami) -p $(oc whoami -t) <docker registry>
```

4. Extract the help scripts from the PPA package
```
tar -xvf <ppa_file> charts && cd charts && tar xvf ibm-cloud-appmgmt-prod-1.5.0.tgz && cd ..
```
5. Create Ingress TLS Secret
```
./charts/ibm-cloud-appmgmt-prod/ibm_cloud_pak/pak_extensions/lib/make-ca-cert-icam.sh my_ProxyHostName ibm-cloud-appmgmt-prod kube-system
```
my_ProxyHostName is fully qualified domain name (FQDN) of your Common Services Proxy. You can get it by oc -n kube-system get route icp-proxy

6. Create masterCA certificate
```
cat <<EOF | kubectl apply -f -
kind: ConfigMap
apiVersion: v1
metadata:
  name: icam-cluster-ca-cert
  namespace: kube-system
data:
  ca_cert.crt: |
$(kubectl -n kube-public get secret ibmcloud-cluster-ca-cert -o jsonpath='{.data.ca\.crt}' | base64 -d | sed 's/^/    /')
EOF
```

7. Get the existing StorageClass definitions as some pods need persistent storage

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

8. Update the config.yaml file (append to the archive_addons section)

```
     icam:
   namespace: kube-system   ## target namespace. keep it kube-system.
   repo: local-charts
   path: ppa_201909052018_prod.tar.gz  ## PPA file location relative to cluster folder
   charts:
   - name: ibm-cloud-appmgmt-prod   # the chart name. Keep it as ibm-cloud-appmgmt-prod for ICAM Server
     values:
       global:
         ingress:
           domain: "icp-console.mcmresidency1-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud"  # replace with your ICP console host name
           port:  443
         icammcm:
           ingress:
             domain: "icp-proxy.mcmresidency1-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud"
             port: 443
             tlsSecret: "ibm-cloud-appmgmt-prod-ingress-tls"
             clientSecret: "ibm-cloud-appmgmt-prod-ingress-client"
         masterIP: "icp-console.mcmresidency1-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud"
         masterPort: 443
         proxyIP: "169.55.103.165"    ##IP of "icp-proxy.mcmresidency1-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud"
         masterCA: 'icam-cluster-ca-cert'
         license: "accept"
         image:
           repository: "docker-registry.default.svc:5000/kube-system"
         persistence:
           storageClassName: "ibmc-block-gold"
       ibm-cloud-appmgmt-prod:
         license: "accept"
       ibm-cem:
         license: "accept"
         productName: "IBM Cloud App Management for Multicloud Manager"
```
   
*NOTE: Please read inline comments*

9. **Run the inception installer**

From the `../cluster` folder and execute the following command
   >docker run -t --net=host -e LICENSE=accept -v $(pwd):/installer/cluster:z -v /var/run:/var/run:z -v /etc/docker:/etc/docker:z --security-opt label:disable ibmcom/icp-inception-amd64:3.2.1-rhel-ee addon

# Post Install

Similar mounted file system ownership issues that were encountered with the CAM installation also exist with ICAM. The following describes the stateful sets that need to be modified and the changes required ...
   
- **zookeeper** 
   
```
oc edit statefulset ibm-cloud-appmgmt-prod-zookeeper
```
   
Add the following lines into the 'initContainers section
   
```
      - args:
        - chown 1001:1001 /var/lib/zookeeper/data
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
        - mountPath: /var/lib/zookeeper/data
          name: data
```

- **cassandra** 
   
```
oc edit statefulset ibm-cloud-appmgmt-prod-cassandra
```
   
Add the following lines after the dnsPolicy line
   
```
      initContainers:
      - args:
        - chown 1001:1001 /opt/ibm/cassandra/data && chown 1001:1001 /opt/ibm/cassandra/logs
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
        - mountPath: /opt/ibm/cassandra/data
          name: data
        - mountPath: /opt/ibm/cassandra/logs
          name: ibm-cloud-appmgmt-prod-cassandralogs
   
```

- **couchdb** 
   
```
oc edit statefulset ibm-cloud-appmgmt-prod-couchdb   
```
   
Add the following lines after the dnsPolicy line

```
    initContainers:
      - args:
        - chown 1001:1001 /opt/couchdb/data
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
        - mountPath: /opt/couchdb/data
          name: data
```

- **kafka** 
   
```
oc edit statefulsets ibm-cloud-appmgmt-prod-kafka   
```
   
Add the following lines after the initContainers line

```
      - args:
        - chown 1001:1001 /var/lib/kafka/data
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
        - mountPath: /var/lib/kafka/data
          name: data
```

- **elastic search** 
   
```
oc edit statefulsets ibm-cloud-appmgmt-prod-elasticsearch   ```
```

   Add the following lines after the dnsPolicy line.
   
   Note: Due to an issue with the kernel settings running in the pod, an additional command has to be run to increase the mmap count. 

```
      initContainers:
      - args:
        - chown 1000:1000 /opt/elasticsearch/data && sysctl -w vm.max_map_count=262144
          && sysctl -p
        command:
        - /bin/sh
        - -c
        image: alpine:latest
        imagePullPolicy: Always
        name: initcontainer
        resources: {}
        securityContext:
          allowPrivilegeEscalation: true
          capabilities:
            add:
            - CHOWN
            - FOWNER
            - DAC_OVERRIDE
            drop:
            - ALL
          privileged: true
          readOnlyRootFilesystem: false
          runAsNonRoot: false
          runAsUser: 0
          seLinuxOptions:
            type: spc_t
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /opt/elasticsearch/data
          name: data
```

OIDC registration with IBM Cloud Private is required to be able to login to IBM Cloud Event Management's UI. As an IBM Cloud Private user with the Cluster Administrator role, run the following kubectl command:

```
kubectl exec -n kube-system -t `kubectl get pods -l release=ibm-cloud-appmgmt-prod -n kube-system | grep "ibm-cloud-appmgmt-prod-ibm-cem-cem-users" | grep "Running" | head -n 1 | awk '{print $1}'` bash -- "/etc/oidc/oidc_reg.sh" "`echo $(kubectl get secret platform-oidc-credentials -o yaml -n kube-system | grep OAUTH2_CLIENT_REGISTRATION_SECRET: | awk '{print $2}')`"
```

**Onboard the LDAP users into IAM**

To be able to access the Event Management UI from the ICP console, you will first need to connect to an LDAP.
For the purpose of the residency, the following instructions where used to create a pod with a [Preloaded openLDAP](https://github.ibm.com/john-webb/cloud-private-bootcamp/blob/master/Labs/Lab%2006%20OpenLDAP.md)

Once the ldap is running and configured via the ICP console, carry out the following to onboard the LDAP user(s) into IAM.

```
cloudctl iam ldaps 
(this lists the ldap information created in the previous step and provides the ID which will be used for the following commands)

cloudctl iam user-import -c bd6f7800-d580-11e9-b54c-e95d0123c7ff -u laura 
(imports the user into IAM)

cloudctl iam user-import -c bd6f7800-d580-11e9-b54c-e95d0123c7ff -u carlos 
(imports the user into IAM)

cloudctl iam accounts 
(used to obtain the account ID)

cloudctl iam user-onboard id-mycluster-account -r PRIMARY_OWNER -u laura 
(configured laura to be the primary account owner)

cloudctl iam user-onboard id-mycluster-account -r MEMBER -u carlos 
(configured carlos to be a member)
```

Now when you log into the ICP console as either 'laura' or 'carlos', you will be able to launch the Event Management UI.
