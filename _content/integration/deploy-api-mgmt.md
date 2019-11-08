---
title: Deploy API Management
weight: 600
---

This page contains guidance on how to configure the APIC release for both on-prem and ROKS.

### Prepare endpoints

We have to define the endpoint for each of the APIC subsystems. We can "construct" the endpoints by adding descriptive "prefixes" to the proxy URL. In the sample described here, the proxy URL was *icp-proxy.icp4i-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud* so we defined the endpoints as follows:

Management - all endpoints:
```
mgmt.icp-proxy.icp4i-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud
```

Gateway - API:
```
gw.icp-proxy.icp4i-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud
```

Gateway - service:
```
gwd.icp-proxy.icp4i-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud
```

Analytics - ingestion:
```
ai.icp-proxy.icp4i-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud
```

Analytics - client:
```
ac.icp-proxy.icp4i-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud
```

Portal - web
```
portal.icp-proxy.icp4i-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud
```

Portal - director:
```
padmin.icp-proxy.icp4i-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud
```

### Obtain the pull secret

To obtain the secret for pulling the image login to the OCP CLI and run:
```
oc get secrets -n apic
```
The pull secret starts with **deployer-dockercfg**, in our case it was:
```
deployer-dockercfg-7mlqd
```

### Create the TLS secret.

Setup the CLI environment, and make sure that **helm** command works correctly, for example run:
```
helm version --tls
```
and make sure that it has the connectivity to the server:
```
Client: &version.Version{SemVer:"v2.12.3", GitCommit:"eecf22f77df5f65c823aacd2dbd30ae6c65f186e", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.12.3+icp", GitCommit:"34e12adfe271fd157db8f9745affe84c0f603809", GitTreeState:"clean"}
```

Run the following command to create the secret:
```
kubectl create secret generic apic-ent-helm-tls --from-file=cert.pem=$HOME/.helm/cert.pem --from-file=ca.pem=$HOME/.helm/ca.pem --from-file=key.pem=$HOME/.helm/key.pem -n apic
```
where **apic-ent-helm-tls** is the name of the secret.

### Increase vm.max_map_count

To check and increase `vm.max_map_count` we would need an *ssh* access to each of the cluster nodes.

The alternative is to create a DaemonSet which will do that for us. Prepare the yaml file with the following content:
```yaml
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  labels:
    k8s-app: sysctl-conf
  name: sysctl-conf
  namespace: kube-system
spec:
  template:
    metadata:
      labels:
        k8s-app: sysctl-conf
    spec:
      containers:
      - command:
        - sh
        - -c
        - sysctl -w vm.max_map_count=262144 && while true; do sleep 86400; done
        image: busybox:1.26.2
        name: sysctl-conf
        resources:
          limits:
            cpu: 10m
            memory: 50Mi
          requests:
            cpu: 10m
            memory: 50Mi
        securityContext:
          privileged: true
      terminationGracePeriodSeconds: 1
```

and run apply it with:

```
oc apply -f sysctl-conf.yaml
```

### Storage class

The **block storage class** is needed for APIC.
You can obtain the class names with
```
oc get storageclass
```

The follwing classes are available on ROKS:
```
NAME                          PROVISIONER         AGE
default                       ibm.io/ibmc-file    9d
ibmc-block-bronze (default)   ibm.io/ibmc-block   9d
ibmc-block-custom             ibm.io/ibmc-block   9d
ibmc-block-gold               ibm.io/ibmc-block   9d
ibmc-block-retain-bronze      ibm.io/ibmc-block   9d
ibmc-block-retain-custom      ibm.io/ibmc-block   9d
ibmc-block-retain-gold        ibm.io/ibmc-block   9d
ibmc-block-retain-silver      ibm.io/ibmc-block   9d
ibmc-block-silver             ibm.io/ibmc-block   9d
ibmc-file-bronze              ibm.io/ibmc-file    9d
ibmc-file-custom              ibm.io/ibmc-file    9d
ibmc-file-gold                ibm.io/ibmc-file    9d
ibmc-file-retain-bronze       ibm.io/ibmc-file    9d
ibmc-file-retain-custom       ibm.io/ibmc-file    9d
ibmc-file-retain-gold         ibm.io/ibmc-file    9d
ibmc-file-retain-silver       ibm.io/ibmc-file    9d
ibmc-file-silver              ibm.io/ibmc-file    9d
```

In our case, we decided to use `ibmc-block-gold`.


### Create an instance

- Open platform navigator and select **API Connect** / **Add new instance**
![Add new instance]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190909_11.png)

- Click *Continue*
![Add new instance]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190909_12.png)

- Define the helm release name, select **apic** namespace and the target cluster_
![Release]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190909_13.png)

- You will receive a warning that the namespace with *ibm-anyuid-hostpath-psp* security policy is needed, but if you, at the same time, receive a warning that the cluster is running all namespaces with that policy by default then for a demo purposes installation, you can leave it as is.
![Policy]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190909_14.png)

- Enter the registry secret name, helm TLS secret name and select storage class:
![Secrets]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190909_15.png)

- Enter the management and portal endpoints:
![Platform endpoints]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190909_16.png)

- Scroll enter the analytics and gateway endpoints:
![Gateway endpoints]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190909_17.png)

- If not already, switch the view to show all parameters
![All params]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190909_17c.png)

- Find the *Routing Type* parameter. For running on OpenShift, the type must be **Route** instead of the default *Ingress*.
![Routung type]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190909_17a.png)

- For the non-production installation, you may switch the mode to **dev**
![Mode]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190909_17d.png)

- and the number of gateway replicas to **1**
![Replicas]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190909_17b.png)

- Click on **Install**, the confirmation message will appear:
![Install]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190909_19.png)

- Navigate to the IBM Cloud Private console, and check the Helm releases (**Workloads > Helm releases**), the APIC helm release should appear on the list
![Helm-rel]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190909_20.png)

- Click on the release to open its properties:
![Rel-prop]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190909_21.png)

- Scroll to see different Kubernetes object under the process of creation:
![Objects]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190909_22.png)

- The most important are pods. You can watch the status here:
![Pods]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190909_23.png)

- At the very bottom of the release page, there are comments with the endpoints that we defined and the we will need later:
![Endpoints]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190909_25.png)

- You may watch the same process in the OpenShift console. Select **apic** project:
![OCP console]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190909_26.png)

- and then **Applications > Pods**:
![Pods]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190909_28.png)

- After a while (be patient) there will be a large number of pods created:
![All pods]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_30.png)

- You can check the status of the pods also with the command:
```
oc get pods -n apic
```
- When deployment is completed, all pods must be in **Running** or **Completed** state. The list of pods should look similar to this one:
```
NAME                                                          READY     STATUS      RESTARTS   AGE
apic1-ibm-apiconnect-icp4i-prod-create-cluster-1-sk2qg        0/1       Completed   0          6d
apic1-ibm-apiconnect-icp4i-prod-operator-0                    1/1       Running     0          6d
apic1-ibm-apiconnect-icp4i-prod-register-oidc-1-h5nzb         0/1       Completed   0          6d
mailhog-55c8c548dc-dphpj                                      1/1       Running     0          6d
r09aaff73f9-analytics-proxy-7f75b7f6c4-gj28b                  1/1       Running     0          6d
r09aaff73f9-apiconnect-cc-0                                   1/1       Running     1          6d
r09aaff73f9-apiconnect-cc-1                                   1/1       Running     1          6d
r09aaff73f9-apiconnect-cc-2                                   1/1       Running     0          6d
r09aaff73f9-apiconnect-cc-repair-1568422800-wlslz             0/1       Completed   0          3d
r09aaff73f9-apiconnect-cc-repair-1568509200-5jzhq             0/1       Completed   0          2d
r09aaff73f9-apiconnect-cc-repair-1568682000-nkwfg             0/1       Completed   0          12h
r09aaff73f9-apim-schema-init-job-zxnpp                        0/1       Completed   0          6d
r09aaff73f9-apim-v2-66b4d4f597-6fpdm                          1/1       Running     3          6d
r09aaff73f9-client-dl-srv-9fd78d7bd-9lkwv                     1/1       Running     0          6d
r09aaff73f9-juhu-8588ddc5cb-254rs                             1/1       Running     0          6d
r09aaff73f9-ldap-6f7d576d9-df9sg                              1/1       Running     0          6d
r09aaff73f9-lur-schema-init-job-nz5fq                         0/1       Completed   0          6d
r09aaff73f9-lur-v2-57c566dfc6-7gfv2                           1/1       Running     1          6d
r09aaff73f9-ui-5f5dbdd578-44fvf                               1/1       Running     0          6d
r307b84ffe1-analytics-client-76474684bb-2h9h7                 1/1       Running     0          6d
r307b84ffe1-analytics-cronjobs-retention-1568683800-2lrz9     0/1       Completed   0          11h
r307b84ffe1-analytics-cronjobs-rollover-1568724300-2mltv      0/1       Completed   0          17m
r307b84ffe1-analytics-ingestion-745b8f9887-tfgj6              1/1       Running     0          6d
r307b84ffe1-analytics-mtls-gw-6bff6f97f4-p2gc9                1/1       Running     0          6d
r307b84ffe1-analytics-operator-545c54ddff-j5bsm               1/1       Running     0          6d
r307b84ffe1-analytics-storage-coordinating-5577557494-vl9nk   1/1       Running     12         6d
r307b84ffe1-analytics-storage-data-0                          1/1       Running     12         6d
r307b84ffe1-analytics-storage-master-0                        1/1       Running     12         6d
r9a3cf2a2d0-cassandra-operator-7f6cdcbbc5-nj9ss               1/1       Running     0          6d
rbcb357bd8b-apic-portal-db-0                                  2/2       Running     0          6d
rbcb357bd8b-apic-portal-nginx-84bc65fb69-2dvdw                1/1       Running     0          6d
rbcb357bd8b-apic-portal-www-0                                 2/2       Running     0          6d
rf9ad2183d2-datapower-monitor-79f7597847-r8grg                1/1       Running     0          6d
rf9ad2183d2-dynamic-gateway-service-0                         1/1       Running     0          6d
```

### SMTP server

In order to configure the API Connect, we need a SMTP server. If we don't have one, we can run the Mailhog, a fake SMTP server ready for any Kubernetes environment.

- Install Mailhog with:
```
helm install --name mailhog stable/mailhog --tls
```

- Mailhog runs service which listens on two ports, 1025 for receiving mails using smtp protocol and 8025 for http access for reading mails.
![SMTP service]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_52.png)

- The service is of ClusteIP type, so in order to read mails, we must change it to the NodePort, or create Route, or simply port-forward the pod. For example, if the pod name (obtained with `oc get pods -n apic`) is *mailhog-55c8c548dc-dphpj* we can run:
```
kubectl port-forward mailhog-55c8c548dc-dphpj 8025:8025 -n apic
```
and then access mails from the local browser on http://127.0.0.1:8025

root@master icp4icontent]# helm init --client-only
Creating /root/.helm/repository 
Creating /root/.helm/repository/cache 
Creating /root/.helm/repository/local 
Creating /root/.helm/plugins 
Creating /root/.helm/starters 
Creating /root/.helm/repository/repositories.yaml 
Adding stable repo with URL: https://kubernetes-charts.storage.googleapis.com 
Adding local repo with URL: http://127.0.0.1:8879/charts 
$HELM_HOME has been configured at /root/.helm.
Not installing Tiller due to 'client-only' flag having been set
Happy Helming!
[root@master icp4icontent]# helm install --name mailhog stable/mailhog --tls
NAME:   mailhog
LAST DEPLOYED: Wed Oct 16 22:13:27 2019
NAMESPACE: apic
STATUS: DEPLOYED

RESOURCES:
==> v1/Service
NAME     TYPE       CLUSTER-IP     EXTERNAL-IP  PORT(S)            AGE
mailhog  ClusterIP  172.30.151.65  <none>       8025/TCP,1025/TCP  1s

==> v1beta1/Deployment
NAME     DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
mailhog  1        1        1           0          1s

==> v1/Pod(related)
NAME                      READY  STATUS             RESTARTS  AGE
mailhog-55c8c548dc-fcdlr  0/1    ContainerCreating  0         1s


NOTES:
**********************************************************************
This chart has been DEPRECATED and moved to its new home:

* GitHub repo: https://github.com/codecentric/helm-charts
* Charts repo: https://codecentric.github.io/helm-charts

**********************************************************************

Mailhog can be accessed via ports 8025 (HTTP) and 1025 (SMTP) on the following DNS name from within your cluster:
mailhog.apic.svc.cluster.local

If you'd like to test your instance, forward the ports locally:

Web UI:
=======

export POD_NAME=$(kubectl get pods --namespace apic -l "app=mailhog,release=mailhog" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward --namespace apic $POD_NAME 8025

SMTP Server:
============

export POD_NAME=$(kubectl get pods --namespace apic -l "app=mailhog,release=mailhog" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward --namespace apic $POD_NAME 102

### Configuring the API Connect

- Open the Cloud Management Console using the previously defined endpoint, in our case it was: https://mgmt.icp-proxy.icp4i-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud/admin

- Select IBM Cloud Private user, default username and password in this case are admin/admin
![Login CMC]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_32.png)

- Under **Resources/Notifications** define the SMTP server
![SMTP]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_51.png)

- For our Mailhog server enter ClusterIP address and port:
![SMTP]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_53.png)

- Under **Settings/Notifications** edit the sender email server:
![SMTP]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_56.png)

- And select the SMTP server defined under resources:
![email]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_57.png)

- Start with the **Topology** configuration
![Topology]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_34.png)

- Register service:
![Register Service]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_35.png)

- Start with the Gateway, select the version that you defined under the Helm release properties when you started creating the instance. In our case it was V5 compatible version:
![Gateway]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_36.png)

- Give some name to the service (e.g. **gateway1**) enter the **endpoints** and click on **Save**:
![Gateway]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_38.png)

- The confirmation message should appear:
![Gateway]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_40.png)

- Click on *Register service* again and select Analytics:
![Analytics]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_43.png)

- Give some name to the service, enter Management endpoint (the one that you defined for **analytics client**) and click **Save**
![Analytics]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_44.png)

- The confirmation appears:
![Analytics]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_46.png)

- Repeat the same with portal:
![Portal]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_48.png)

- The confirmation appears again:
![Portal]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_62.png)

- Click on **Associate Analytics Service** to associate analytics with the gateway:
![Associate analytics]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_63.png)

- Select the analytics service:
![Associate analytics]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_64.png)

- Click on **Provider organizations** and add new organization:
![ProvOrg]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_66.png)

- Give some name to the organization:
![ProvOrg]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_67.png)

- Define the owner
![ProvOrg]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_68.png)

- After you submit the organization will appear on the list:
![ProvOrg]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_69.png)

- Navigate to the API Manager, in our case the endpoint was:
https://mgmt.icp-proxy.icp4i-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud/manage

- Login as the owner (defined in the previous step), the API Manager page should open:
![API Mgr]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_70.png)

- You can navigate to the catalog:
![Sandbox]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_71.png)

- and create portal
![Create portal]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_73.png)

- You can also assign the gateway to the catalog
![Catalog]({{ site.github.url }}/assets/img/integration/apic-roks/Snip20190910_79.png)

With that, your API Connect instance is ready for usage. 































---
