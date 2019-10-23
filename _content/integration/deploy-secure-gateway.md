---
title: Deploy Secure Gateway
weight: 600
---

- [Introduction](#introduction)
- [Prepare Installation](#prepare-installation)
- [Begin Installation](#begin-installation)
- [Validate Installation](#validate-installation)

### Introduction
This page contains guidance on how to configure the Datapower Gateway release for both on-prem and ROKS.

### Prepare Installation

1. **Change project to eventstreams**
   ```
   oc project datapower
   ```

### Begin Installation  
1. Go to CP4I Platform Home. Click **Add new instance** inside the **DataPower** tile.  

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
   oc get pods -n datapower
   NAME                                      READY     STATUS    RESTARTS   AGE
   dp-1-ibm-datapower-icp4i-fb888677-mvd9q   1/1       Running   0          3m
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