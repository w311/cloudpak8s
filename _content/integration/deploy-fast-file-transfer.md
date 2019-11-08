---
title: Deploy Fast File Transfer
weight: 600
---

- [Introduction](#introduction)
- [Prepare Installation](#prepare-installation)
- [Begin Installation](#begin-installation)
- [Validate installation](#validate-installation)

### Introduction
This page contains guidance on how to configure the Aspera release for both on-prem and ROKS.

### Prepare Installation

1. **Change project to aspera**
   ```
   oc project aspera
   ```
2. **Use Node Labels:**  

    In order to ensure high availability, the Aspera Swarm services will attempt to create a configurable number of pods on each node in the Kubernetes cluster. The nodes on which the receiver pods are running can be restricted via the nodeLabels values.  
    
    For example, the following would restrict pods to nodes with the `node-role.kubernetes.io/ascp=true` label or `node-role.kubernetes.io/noded=true` label.

    ```
    ascpSwarm:
    config:
        nodeLabels:
        node-role.kubernetes.io/ascp: "true"

    nodedSwarm:
    config:
        nodeLabels:
        node-role.kubernetes.io/noded: "true"
    ```      
    
    Label Nodes using the command  

    ```
    oc label node <node-name> node-role.kubernetes.io/<role>=true
    ```

3. **Additional RBAC Requirements:**  

    The following RBAC resources are also required before you deploy the chart. Use the command `oc create -f <filename.yaml>`

    - **Cluster Admin**
      - [ClusterRole]({{site.github.url}}/assets/img/integration/aspera/files/cluster-admin-clusterrole.yaml)
    - **Namespace User**  
      Substitute {{ NAMESPACE }} with the namespace the chart will be deployed in.
      - [ClusterRoleBinding]({{site.github.url}}/assets/img/integration/aspera/files/namespace-user-clusterrole.yaml)
      - [Role]({{sit.github.url}}/assets/img/integration/aspera/files/namespace-user-role.yaml)
      - [RoleBinding]({{site.github.url}}/assets/img/integration/aspera/files/namespace-user-rolebinding.yaml)
      - [RoleBinding]({{site.github.url}}/assets/img/integration/aspera/files/hsts-prod-rolebinding.yaml)
      - [ServiceAccount]({{site.github.ur}}/assets/img/integration/aspera/files/apsera-sa-role.yaml) - get the value for imagePullSecrets from oc get secret -n aspera. Copy the secret that begins with docker-deployercfg-xxxxx.
      - [Secret Generation Role]({{site.github.ur}}/assets/img/integration/aspera/files/secret-gen-role.yaml)
      - [Secret Generation RoleBinding]({{site.github.url}}/assets/img/integration/aspera/files/secret-gen-rolebinding.yaml)
      - [Secret Generation ServiceAccount]({{site.github.url}}/assets/img/integration/aspera/files/secret-gen-sa.yaml)  

4. **Create the secrets**
   
   ```
   oc create secret generic aspera-servcer --from -file=ASPERA_LICENSE="./aspera-license" --from-literal=TOKEN_ENCRYPTION_KEY="my_encryption_key"

   kubectl create secret generic asperanode-nodeadmin --from-literal=NODE_USER="myuser" --from-literal=NODE_PASS="mypassword"
   
   kubectl create secret generic asperanode-accesskey --from-literal=ACCESS_KEY_ID="my_access_key" --from-literal=ACCESS_KEY_SECRET="my_access_key_secret"
   ```

### Begin Installation
1. Go to CP4I Platform Home. Click **Add new instance** inside the **Aspera** tile.    
   
![Platform Home]({{site.github.url}}/assets/img/integration/aspera/cp4i-home-aspera.png)
1. A window will pop up with a description of the requirements for installing. Click **Continue** to the helm chart deployment configuration.
   ![Aspera requirements dialog]({{site.github.url}}/assets/img/integration/aspera/cp4-aspera-continue.png)
2. Click **Overview** to view the chart information and pre-reqs that were covered in [Prepare Installation](#prepare-installation).
   ![Aspera Chart Overview]({{site.github.url}}/assets/img/integration/aspera/aspera-chart-overview.png)
3. Click **Configure**
4. Enter the Helm release name. In our example, **Aspera-1**
5. Enter Target Namespace - **Aspera**
6. Select a Cluster - **local-cluster**.
7. Check the license agreement.
   ![aspera-install-1]({{site.github.url}}/assets/img/integration/aspera/aspera-install-1.png)
8. Under Parameters -> Quick start
   1. Ingress - icp-proxy address defined during icp / common-services installation - icp-proxy.\<openshift-router-domain>  
   2. Aspera Node - Server Secret - the secret created using the license - **aspera-server**
   3. Aspera Event Journal - Kafka Host - use hostname of bootstrap server of existing eventstreams installation. Get this value from the Eventstreams web ui.  
   4. Aspera Rproxy - address of cluster proxy  
QUICK START PIC
9.  Click All Parameters
10. Uncheck production usage
11. Image Pull Secret - the secret used to pull images for install from the docker registry. You can get this secret by typing the command `oc get secret -n aspera`. copy the name of the secret beginning with deployer-dockercfg-xxxxx.
12. Scroll down to the Redis section.
13. Check Persistence Enabled.
14. Check Use dynamic provisioning.
15. Storage Class Name - enter storage class for file storage
16. Image Pull Secret - same as step 11.  
    PICK ASPERA-INSTALL-REDIS.PNG
17. Scroll down to Persistence
18. Enter the same Storage Class Name as step 15
19. Proceed to the section Aspera Node
20. Node Admin Secret - enter the nodeadmin secret created in the preious section - asperanode-nodeadmin
21. Access Key Secret - enter the access key secret created in the previous section - asperanode-accesskey
22. Proceed to the section - Aspera Event Journal
23. Kafka Port - change to Kafka port found in Eventstreams bootstrapi server.  
    PICK ASPERa event JORNAL
24. Proceed to section Ascp Swarm
25. Node Labels - enter the node labels created in the previous section for identifying ascp swarm nodes -  -node-role.kubernetes.io/ascp: true
26. Proceed to section - Noded Swarm
27. Node Labels - set to the node label created for noded from the previous section - -node-role.kubernetes.io/noded: true
28. Scroll to section - Sch
29. Image Pull Secret - deployer-dockercfg secret

### Validate installation    

1. View all pods running
    ```
    NAME                                                       READY     STATUS      RESTARTS   AGE
    aspera-1-aspera-hsts-aej-d8c5b5569-24vh8                   1/1       Running     0          3m
    aspera-1-aspera-hsts-aej-d8c5b5569-68nvj                   1/1       Running     0          3m
    aspera-1-aspera-hsts-aej-d8c5b5569-v5xgb                   1/1       Running     0          3m
    aspera-1-aspera-hsts-ascp-loadbalancer-75849464b-lq8lz     1/1       Running     0          3m
    aspera-1-aspera-hsts-ascp-swarm-54c98cb6bb-hznw5           2/2       Running     0          3m
    aspera-1-aspera-hsts-create-access-key-v1-24hdg            0/1       Completed   0          3m
    aspera-1-aspera-hsts-http-proxy-8b86df4f-8hd6d             1/1       Running     0          3m
    aspera-1-aspera-hsts-node-api-796f5c8ccc-r9xs2             2/2       Running     0          3m
    aspera-1-aspera-hsts-node-master-788774bbc7-8sl2s          2/2       Running     0          3m
    aspera-1-aspera-hsts-noded-loadbalancer-844977799b-f4gd6   1/1       Running     0          3m
    aspera-1-aspera-hsts-noded-swarm-6b8498fd-slj8g            2/2       Running     0          3m
    aspera-1-aspera-hsts-prometheus-endpoint-bc5974d79-4fv4t   2/2       Running     0          3m
    aspera-1-aspera-hsts-prometheus-endpoint-bc5974d79-d426s   2/2       Running     0          3m
    aspera-1-aspera-hsts-prometheus-endpoint-bc5974d79-t7f8l   2/2       Running     0          3m
    aspera-1-aspera-hsts-stats-5c5c8cc8fc-c2gbr                2/2       Running     0          3m
    aspera-1-aspera-hsts-stats-5c5c8cc8fc-lcbxr                2/2       Running     0          3m
    aspera-1-aspera-hsts-stats-5c5c8cc8fc-qpj5l                2/2       Running     0          3m
    aspera-1-aspera-hsts-tcp-proxy-748b6bb64-j478m             1/1       Running     0          3m
    aspera-1-redis-ha-sentinel-0                               1/1       Running     0          3m
    aspera-1-redis-ha-sentinel-1                               1/1       Running     0          2m
    aspera-1-redis-ha-sentinel-2                               1/1       Running     0          1m
    aspera-1-redis-ha-server-0                                 1/1       Running     0          3m
    aspera-1-redis-ha-server-1                                 1/1       Running     0          2m
    aspera-1-redis-ha-server-2                                 1/1       Running     0          2m
    ```

2. 

