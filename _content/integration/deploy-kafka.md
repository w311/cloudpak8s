---
title: Deploy Kafka
weight: 600
---

- [Introduction](#introduction)
- [Prepare Installation](#prepare-installation)
- [Begin Installation](#begin-installation)
- [Validate Installation](#validate-installation)

### Introduction
This page contains guidance on how to configure the Aspera release for both on-prem and ROKS.

### Prepare Installation

1. **Change project to eventstreams**
   ```
   oc project eventstreams
   ```
2. **Resources Required:**  

    If you enable message indexing (which is enabled by default), then you must have the vm.max_map_count property set to at least 262144 on all IBM Cloud Private nodes in your cluster (not only the master node). Please note this property may have already been updated by other workloads to be higher than the minimum required. Run the following commands on each node:

    ```
    sudo sysctl -w vm.max_map_count=262144

    echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf
    ```

### Begin Installation  
1. Go to CP4I Platform Home. Click **Add new instance** inside the **Event Streams** tile.  

{%
  include figure.html
  src="/assets/img/integration/es/cp4i-home-es.png"
  alt="Platform Home"
  caption="Platform Home"
%}  

1. A window will pop up with a description of the requirements for installing. Click **Continue** to the helm chart deployment configuration.  
  {%
    include figure.html
    src="/assets/img/integration/es/cp4i-es-continue.png"
    alt="Requirements Dialog"
    caption="Requirements Dialog"
  %}
   
2. Click **Overview** to view the chart information and pre-reqs that were covered in [Prepare Installation](#prepare-installation).
3. Click **Configure**
4. Enter the Helm release name. In our example, **es-1**
5. Enter Target Namespace - **eventstreams**
6. Select a Cluster - **local-cluster**.
7. Check the license agreement.  
  
  {%
    include figure.html
    src="/assets/img/integration/es/es-install-1.png"
    alt="Event Streams Install Chart 1"
    caption="Event Streams Install Chart 1"
  %}

8. Under Parameters click **All Parameters** to expand. 
   1. Ingress - icp-proxy address defined during icp / common-services installation - icp-proxy.\<openshift-router-domain>  
   2. Image Pull Secret - the secret used to pull images for install from the docker registry. You can get this secret by typing the command `oc get secret -n eventstreams`. copy the name of the secret beginning with deployer-dockercfg-xxxxx.  
   ![Global Install Settings]({{site.github.url}}/assets/img/integration/es/cp4i-es-install-2.png)
9.  Scroll down to External access settings - enter the proxy address - **icp-proxy.\<openshift-router-domain>.**
    ![externa access settings]({site.github.url}/assets/img/integration/es/es-install-3.png)
10. Scroll to the bottom. Click **Install**.

### Validate Installation  
1. check pods using the command line
   ```
   oc get pods -n eventstreams
   NAME                                                    READY     STATUS      RESTARTS   AGE
    es-1-ibm-es-access-controller-deploy-5db9c7fb45-gz2nm   2/2       Running     0          3m
    es-1-ibm-es-access-controller-deploy-5db9c7fb45-p2whr   2/2       Running     0          3m
    es-1-ibm-es-collector-deploy-76d7fb99bd-vnfqd           2/2       Running     0          3m
    es-1-ibm-es-elastic-sts-0                               2/2       Running     0          3m
    es-1-ibm-es-elastic-sts-1                               2/2       Running     0          3m
    es-1-ibm-es-indexmgr-deploy-5b8bd89c4b-6pxs7            2/2       Running     0          3m
    es-1-ibm-es-kafka-sts-0                                 5/5       Running     2          3m
    es-1-ibm-es-kafka-sts-1                                 5/5       Running     1          3m
    es-1-ibm-es-kafka-sts-2                                 5/5       Running     2          3m
    es-1-ibm-es-proxy-deploy-6f8959775-89j4m                1/1       Running     0          3m
    es-1-ibm-es-proxy-deploy-6f8959775-dlnh6                1/1       Running     0          3m
    es-1-ibm-es-proxy-deploy-6f8959775-vx9ps                1/1       Running     0          3m
    es-1-ibm-es-rest-deploy-8667789594-qssvf                3/3       Running     0          3m
    es-1-ibm-es-rest-producer-deploy-8f8c79f8f-mvldm        1/1       Running     0          3m
    es-1-ibm-es-rest-proxy-deploy-849b45f5c9-s7p8x          1/1       Running     0          3m
    es-1-ibm-es-schemaregistry-sts-0                        2/2       Running     0          3m
    es-1-ibm-es-ui-deploy-5d44c64-mgg9j                     2/2       Running     0          3m
    es-1-ibm-es-ui-oauth2-client-reg-v4hmv                  0/1       Completed   0          12h
    es-1-ibm-es-zookeeper-sts-0                             2/2       Running     0          3m
    es-1-ibm-es-zookeeper-sts-1                             2/2       Running     0          3m
    es-1-ibm-es-zookeeper-sts-2                             2/2       Running     0          3m
    ```
2. Make sure the bootstrap server is running
   1. Click **es-1** on Platform Home.  
      <figure class="figure">
        <img class="figure__image {% unless include.border == false %}figure__image--border{% endunless %} {% unless include.lightbox == false %}figure__image--lightbox{% endunless %}"
            src="{{ site.github.url }}/assets/img/integration/es/es-1-platform-home.png"
            alt="Platform Home">
        <figcaption class="figure__caption">
          Platform Home
        </figcaption>
      </figure> 
   1. Click **Connect to this cluster**.
      <figure class="figure">
        <img class="figure__image {% unless include.border == false %}figure__image--border{% endunless %} {% unless include.lightbox == false %}figure__image--lightbox{% endunless %}"
            src="{{ site.github.url }}/assets/img/integration/es/es-1-home.png"
            alt="Eventstreams Home">
        <figcaption class="figure__caption">
          Eventstreams Home
        </figcaption>
      </figure> 
   2. Make sure the bootstrap server shows an address.  
      <figure class="figure">
        <img class="figure__image {% unless include.border == false %}figure__image--border{% endunless %} {% unless include.lightbox == false %}figure__image--lightbox{% endunless %}"
            src="{{ site.github.url }}/assets/img/integration/es/es-bootstrap-server.png"
            alt="Eventstreams Bootstrap Server">
        <figcaption class="figure__caption">
          Eventstreams Bootstrap Server
        </figcaption>
      </figure>