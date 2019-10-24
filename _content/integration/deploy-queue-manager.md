---
title: Deploy Messaging and Queue Manager
weight: 800
---

- 
{:toc}

This page provides the guidance for installing MQ for both Red Hat OpenShift on-prem and on IBM Cloud.

### Create MQ instance in Cloud Pak for Integration

1. Create an instance of MQ queue manager by clicking on “Add new instance” in the MQ tile in Platform Navigator.  
   ![Add New Instance]({{site.github.url}}/assets/img/integration/mq/add-mq-instance.png)
2. This will open a pop up window showing requirements for deploying MQ as shown below. Click **Continue**.   
   ![Add MQ]({{site.github.url}}/assets/img/integration/mq/add-mq.png)
3. This will open the MQ helm chart to deploy MQ to the container platform as shown below.  
   ![MQ Helm Chart]({{site.github.url}}/assets/img/integration/mq/mq-helm-chart.png)
4. Click **Overview** to review the requirements to deploy MQ chart.  
    ![MQ Helm Chart Overview]({{site.github.url}}/assets/img/integration/mq/mq-helm-overview.png)
5. MQ chart requires the following Role and Rolebinding.
   1. Role: 
      ```
      apiVersion: rbac.authorization.k8s.io/v1
      kind: Role
      metadata:
      name: ibmcloud-cluster-ca-cert-fix
      namespace: kube-public
      rules:
      - apiGroups:
          - ""
        resources:
          - secrets
        verbs:
          - get
      ```
    2. Copy the above yaml into a file ***mq-role.yaml*** and run the below command to create the Role.  
        `oc apply -f mq-role.yaml`
    3.  Rolebinding:
        ```
        apiVersion: rbac.authorization.k8s.io/v1
        kind: RoleBinding
        metadata:
        name: ibmcloud-cluster-ca-cert-fix
        namespace: kube-public
        roleRef:
        apiGroup: rbac.authorization.k8s.io
        kind: Role
        name: ibmcloud-cluster-ca-cert-fix
        subjects:
        - apiGroup: rbac.authorization.k8s.io
        kind: Group
        name: system:authenticated
        - apiGroup: rbac.authorization.k8s.io
        kind: Group
        name: system:unauthenticated
        ```
    4.  Copy the above yaml into a file ***mq-rolebinding.yaml*** and run the previous command to create rolebinding
        `oc apply -f mq-rolebinding.yaml`
6.	MQ chart also requires a PodSecurityPolicy to be bound to the target namespace. In a default installation the namespace used is ***mq*** and this step may not be required. 

7.	The chart may also require SecurityContextContraints in a non-default installation

8.	MQ also requires Storage class or Persistent volume to be pre-define if persistence is being used. It is possible to deploy MQ chart without using persistence. 

9.	Obtain an image pull secret using the command below:

    To obtain the secret for pulling the image login to the OCP CLI and run:
    ```
    oc get secrets -n mq
    ```
    The pull secret starts with **deployer-dockercfg**

10.	After performing the above pre-requisites, click on **Configuration** tab to provide the values required to deploy MQ chart. 

11.	Provide the name for the chart, select **mq** as Target namespace and select **local-cluster** as Target-Cluster. Also check the ‘License’ box to accept license as shown below.  
    ![MQ Configuration 1]({{site.github.url}}/assets/img/integration/mq/mq-helm-1.png)

12.	Next, click to expand ‘All parameters’ to configure the chart for deployment.  
    ![MQ Configuration 2]({{site.github.url}}/assets/img/integration/mq/mq-helm-2.png)

13.	Uncheck the box “Production usage” and select ‘Always’ for Image pull policy as shown below. Note, the Image repository, Image tag are pre-selected.   
    ![MQ Configuration 3]({{site.github.url}}/assets/img/integration/mq/mq-helm-3.png)

14.	Click on ‘Generate Certificate’ as shown below.  
    ![MQ Configuration 4]({{site.github.url}}/assets/img/integration/mq/mq-helm-4.png)

15.	Provide the Cluster hostname as shown below. This is the host name of the proxy configured in the config.yaml during installation.  
    ![MQ Configuration 5]({{site.github.url}}/assets/img/integration/mq/mq-helm-5.png)

16.	Provide Storage Class name. This will be pre-configured by the platform administrator. The storage class being used here is ‘glusterfs-storage’ as shown below.  
    ![MQ Configuration 6]({{site.github.url}}/assets/img/integration/mq/mq-helm-6.png)

17.	Scroll down the chart till you see Queue manager and enter the Queue manager name as shown below. Leave the default values for rest of the parameters in the chart.  
    ![MQ Configuration 7]({{site.github.url}}/assets/img/integration/mq/mq-helm-7.png)

18.	Click on Install button at the bottom of the chart to deploy.  
    ![MQ Configuration Install]({{site.github.url}}/assets/img/integration/mq/mq-helm-install.png)

19.	A pop up window will appear with ‘Installation started’ message. Click on the Home link as shown below.   
    ![MQ Installation Started]({{site.github.url}}/assets/img/integration/mq/mq-installation-started.png)

20.	The MQ instance ‘mq10’ will appear in the Platform Navigator as shown below.  
    ![MQ Installed]({{site.github.url}}/assets/img/integration/mq/mq-installed.png)

21.	Click on the link ‘mq10’ to open MQ console for the queue manager ‘MQ10’ that was deployed in the chart. The below window will appear. Click on the link ‘Loading mq10’ to open a new browser window and accept the certificate.  
    ![MQ first load]({{site.github.url}}/assets/img/integration/mq/mq-first-load.png)

22.	Accept the certificate in the browser to open MQ console.  
    ![MQ Accept Crt]({{site.github.url}}/assets/img/integration/mq/mq-accept-cert.png)

23.	MQ console will open showing the queue manager QM10 as shown below.  
    ![MQ Console]({{site.github.url}}/assets/img/integration/mq/mq-console.png)

This completes deploy of MQ chart in Cloud Pak for Integration.