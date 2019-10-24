---
title: Install Cloud Pak for Data on Red Hat OpenShift on IBM Cloud
weight: 300
---

## Create an Openshift cluster in IBM Cloud

1 Go to cloud.ibm.com.

{%
  include figure.html
  src="/assets/img/cp4d/ibm-cloud.jpg"
  alt="IBM Cloud"
  caption="IBM Cloud"
%}

2 Click on the menu on the left top of the webpage, and then click on "kubernetes".

{%
  include figure.html
  src="/assets/img/cp4d/kubernetes.jpg"
  alt="Kubernetes"
  caption="Kubernetes"
%}

3 Click on the button: "create cluster".

{%
  include figure.html
  src="/assets/img/cp4d/create-cluster.jpg"
  alt="Create Cluster"
  caption="Create Cluster"
%}

4 Choose settings for the cluster and here is the example customized configuration:
  
     Plan: "Standard"
     Cluster Type and Version: "Openshift" v3.11
     Cluster name: "cp4d-ocp"
     Tag: "v1"
     Location: 
       Availability: "Single Zone"
       Worker Zone: "Washington DC 06"
       Master Service Endpoint: "Public endpoint only"
     Default Worker Pool: "16 vCPUs 64GB RAM"
     Worker nodes: 3.
     
     
 {%
  include figure.html
  src="/assets/img/cp4d/setting.jpg"
  alt="Cluster Setting"
  caption="Cluster Setting"
%}
  
 5 Click on the button: "Create Cluster" and it may take 10-20 minutes to finished the deployment.
 
  {%
  include figure.html
  src="/assets/img/cp4d/final-create.jpg"
  alt="Create Cluster"
  caption="Create Cluster"
%}
 
   {%
  include figure.html
  src="/assets/img/cp4d/cluster-installing.jpg"
  alt="Cluster Creating"
  caption="Cluster Creating"
%}
 
## Set up CLI tools for IBM Cloud and Openshift

 1 Run this command in your terminal: 
 
     curl -sL https://ibm.biz/idt-installer | bash
 
 2 Download the openshift CLI and extract the zip file to somewhere you want to use as "oc" command location.
 

## Validate the created OCP cluster

  1 Make sure the state of the cluster is "Normal".
  
 {%
  include figure.html
  src="/assets/img/cp4d/cluster-status.jpg"
  alt="Cluster Status"
  caption="Cluster Status"
%}
  
  2 Go to the web console of Openshift cluster and check the status of each component in OCP.
  
  {%
  include figure.html
  src="/assets/img/cp4d/OCP-mainpage.jpg"
  alt="Openshift Mainpage"
  caption="Openshift Mainpage"
%}
  
  3 Copy the login command and run it in the terminal of you client computer.
  
  {%
  include figure.html
  src="/assets/img/cp4d/copy-login.jpg"
  alt="Copy Login Command"
  caption="Copy Login Command"
%}  

  {%
  include figure.html
  src="/assets/img/cp4d/oc-login.jpg"
  alt="Run 'oc login'"
  caption="Run 'oc login'"
%} 
  
  4 Run commands "oc get no" and "oc get pods" (make sure you have "oc" included in your system envrionment path).
  
   {%
  include figure.html
  src="/assets/img/cp4d/oc-get-po.jpg"
  alt="Run command 'oc get no'"
  caption="Run command 'oc get no'"
%}  

