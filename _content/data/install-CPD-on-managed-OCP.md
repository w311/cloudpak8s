---
title: Install CPD on Managed OCP in IBM Cloud
weight: 400
---

## Create installation script and run it in terminal.

1 Copy the content of install-cp4data.sh from IBM Knowledge Center: 

  [Installing Cloud Pak for Data on managed Red Hat OpenShift on IBM Cloud](https://www.ibm.com/support/knowledgecenter/en/SSQNUZ_2.1.0/com.ibm.icpdata.doc/zen/install/openshift-softlayer.html)
  
2 Change the content of DOCKER-REGISTRY related parameters and here is an example in IBM Cloud environment (password is not provided for security reason): 

    DOCKER_REGISTRY="us.icr.io/release2_1_0_1_base"
    DOCKER_REGISTRY_USER="iamapikey"
    DOCKER_REGISTRY_PASS="<<inform here the docker password>>"

 3 Run the shell script:
 
 
    ./install-cp4data.sh zen
    
    

## Start CPD deployment in Openshift webconsole.

  1 In the OpenShift container platform, go to the created namespace.
  
  {%
  include figure.html
  src="/assets/img/cp4d/ocp-name-space.jpg"
  alt="Go to Namespace"
  caption="Go to Namespace"
%}

  2 Click Select from Project. Alternatively, you can go to the Catalog Menu and select Cloud Pak for Data.

{%
  include figure.html
  src="/assets/img/cp4d/select-from-project.jpg"
  alt="Select From Project"
  caption="Select From Project"
  %}
  
  3 In the Selection window, click Cloud Pak for Data. Click Next.

{%
  include figure.html
  src="/assets/img/cp4d/select-cpd.jpg"
  alt="Selection Window"
  caption="Selection Window"
  %}
  
  4 In the Information window, click Next.
  
  {%
  include figure.html
  src="/assets/img/cp4d/information-window-next.jpg"
  alt="Information Window"
  caption="Information Window"
  %}
  
  5 In the Configuration window, fill in your cluster environment information. Ensure the StorageClass is correct. Click Create. 
  
  {%
  include figure.html
  src="/assets/img/cp4d/configuration-window.jpg"
  alt="Configuration Window"
  caption="Configuration Window"
  %}
  
  Here is an example StorageClass:
  
       ibmc-file-gold
  
  6 In the Results window, click Continue on the project overview to see the status.

{%
  include figure.html
  src="/assets/img/cp4d/results-window.jpg"
  alt="Results Window"
  caption="Results Window"
  %}
  

## Monitor the deployment process.

  1 Keep monitoring the log of deployment. In a correct order, first step will be deploying pod: "cp4data-installer-1-sp28b" and then you can view the log of the this pod to monitor the process the all the other components of CPD.
  
  2 Use command "oc get pods" to check the status in the terminal. 
  
  3 it may take up to 2 hours to finish the deployment and finally you will have 83 pods running!
  
     qijuns-mbp:OCP qijunwang$ oc get pods -n zen | wc -l
      
     84
     
     qijuns-mbp:OCP qijunwang$ oc get pods -n zen | grep -v Running | grep -v Completed
     
     NAME                   READY     STATUS    RESTARTS   AGE
      
     qijuns-mbp:OCP qijunwang$ 

  
## Known issues and resolutions.

   1  Failed to pull images from Docker REGISTRY.
   
   Log of the error:
   
     2:08:36 PM     cp4data-installer-1-87cmn     Pod     Warning     Failed      Error: ImagePullBackOff
     3 times in the last minute
     2:08:36 PM     cp4data-installer-1-87cmn     Pod     Normal     Back-off      Back-off pulling image "cp.stg.icr.io/cp /cp4d/cp4d-installer:v1"
     3 times in the last minute
     2:08:22 PM     cp4data-installer-1-87cmn     Pod     Warning     Failed      Failed to pull image "cp.stg.icr.io/cp/cp4d/cp4d-installer:v1": rpc error: code = Unknown desc = unable to retrieve auth token: invalid username/password
     3 times in the last minute
     2:08:22 PM     cp4data-installer-1-87cmn     Pod     Warning     Failed      Error: ErrImagePull
     3 times in the last minute
     2:08:22 PM     cp4data-installer-1-87cmn     Pod     Normal     Pulling      pulling image "cp.stg.icr.io/cp/cp4d/cp4d-installer:v1"
     3 times in the last minute
    2:07:27 PM     cp4data-installer-1-87cmn     Pod     Warning     Failed Create Pod Sand Box      Failed create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_cp4data-installer-1-87cmn_zen_d412daf1-cf3e-11e9-bd0c-2a0a29181891_0(be9ae5031560dc694d70d4d0e41c52e1b95832493b99efef92ce168251d80581): context deadline exceeded


  Resolution:
  
     Change the Docker Registry URL to "us.icr.io/release2_1_0_1_base".
     
  2  Stuck by "services "ibm-nginx-svc" not found".
     
   Log of the error: 
     
     installctl/cmd.glob..func3(0x2978720, 0xc0001a22a0, 0x0, 0xe)
    /root/go/src/github.ibm.com/privatecloud/installctl/cmd/deploy.go:39 +0x20
    github.com/spf13/cobra.(*Command).execute(0x2978720, 0xc0001a21c0, 0xe, 0xe, 0x2978720, 0xc0001a21c0)
    /root/go/pkg/mod/github.com/spf13/cobra@v0.0.0-20190805155617-b80588d523ec/command.go:833 +0x2ae
    github.com/spf13/cobra.(*Command).ExecuteC(0x2978c20, 0x4, 0x17e2509, 0x32)
    /root/go/pkg/mod/github.com/spf13/cobra@v0.0.0-20190805155617-b80588d523ec/command.go:917 +0x2fc
    github.com/spf13/cobra.(*Command).Execute(...)
    /root/go/pkg/mod/github.com/spf13/cobra@v0.0.0-20190805155617-b80588d523ec/command.go:867
    installctl/cmd.Execute()
    /root/go/src/github.ibm.com/privatecloud/installctl/cmd/root.go:38 +0x32
    main.main()
    /root/go/src/github.ibm.com/privatecloud/installctl/main.go:34 +0x20
    No resources found.
    Error from server (NotFound): services "ibm-nginx-svc" not found
    
  Resolution:
  
    Restart the pod: "cp4data-installer" by "oc delete" in terminal or Openshift webconsole.
    
 3 Stuck by "unbound PersistentVolumeClaims".
     
   Log of the error: 
   
     time="2019-09-04T19:35:03Z" level=info msg="Release present on the cluster in DEPLOYED state. Upgrading..."
     time="2019-09-04T19:35:03Z" level=info msg="Upgrading release zen-0005-boot"
     time="2019-09-04T19:35:04Z" level=info msg="Release Deployment Status: zen-0005-boot - Deploy: -1/1 - Pod: 0/0 - Job: 0/0 - Pvc: 0/1"
     time="2019-09-04T19:35:05Z" level=info msg="Release Deployment Status: zen-0005-boot - Deploy: 0/1 - Pod: 0/1 - Job: 0/0 - Pvc: 0/1"
     no error or warning, but no progress.
    Events:
     Type     Reason            Age                     From               Message
     ----     ------            ----                    ----               -------
     Warning  FailedScheduling  2m15s (x25 over 3m18s)  default-scheduler  pod has unbound PersistentVolumeClaims (repeated 3 times)
     
   Resolution:
   
    Change the storageclass to "ibmc-file-gold" and restart the deployment.
    
  4 Stuck by wrong report information
  
  Log of the error:
  
    time="2019-09-04T20:11:23Z" level=info msg="Values override output: global:\n  architecture: amd64\n  baseInstaller: false\n  ibmProduct: zen\n  userHomePVC:\n    persistence:\n      existingClaimName: \"\"\n      size: 100Gi\n  virtualIP: \"\"\nimagemgmt:\n  mgmtPlatform: openshift\n  nodeSelector:\n    compute: \"true\"\nnginxRepo:\n  resolver: kubernetes.default\nusermgmt:\n  showK8sMgmt: false\nzenCoreApi:\n  noTls: true\n  tillerNamespace: zen\nzenProxy:\n  serviceType: ClusterIP\nzenRedis:\n  image:\n    tag: '#REDIS_TAG#'\n"
    time="2019-09-04T20:11:23Z" level=info msg="Installing release zen-0015-setup"
    time="2019-09-04T20:11:57Z" level=panic msg="Could not get the status of the release. Reason: rpc error: code = Unknown desc = getting deployed release \"zen-0015-setup\": release: \"zen-0015-setup\" not found"
    panic: (*logrus.Entry) (0x176bd40,0xc00040afc0)goroutine 3405 [running]:
    github.com/sirupsen/logrus.Entry.log(0xc00009c240, 0xc0004e52c0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, ...)
    /root/go/pkg/mod/github.com/sirupsen/logrus@v1.2.0/entry.go:216 +0x2ce
    
  Resolution:
  
    Delete the installation pod.
    
 5 Solr, Kafka and cassendra pods failed with similar message.
 
  Log of the error:
  
    [2019-09-04 21:38:20,833] ERROR Failed to create or validate data directory /var/lib/kafka/data (kafka.server.LogDirFailureChannel)
    java.io.IOException: Failed to create data directory /var/lib/kafka/data
    at kafka.log.LogManager$$anonfun$createAndValidateLogDirs$1.apply(LogManager.scala:158)
    at kafka.log.LogManager$$anonfun$createAndValidateLogDirs$1.apply(LogManager.scala:149)
    at scala.collection.mutable.ResizableArray$class.foreach(ResizableArray.scala:59)
    at scala.collection.mutable.ArrayBuffer.foreach(ArrayBuffer.scala:48)
    at kafka.log.LogManager.createAndValidateLogDirs(LogManager.scala:149)
    at kafka.log.LogManager.<init>(LogManager.scala:80)
    at kafka.log.LogManager$.apply(LogManager.scala:990)
    at kafka.server.KafkaServer.startup(KafkaServer.scala:237)
    at kafka.server.KafkaServerStartable.startup(KafkaServerStartable.scala:38)
    at kafka.Kafka$.main(Kafka.scala:75)
    at kafka.Kafka.main(Kafka.scala)
    [2019-09-04 21:38:20,839] ERROR Shutdown broker because none of the specified log dirs from /var/lib/kafka/data can be created or validated (kafka.log.LogManager)
    
    
  Resolution:
  
  Copy and run the follwing shell script and then run it by "./iisee-fix.sh zen".
  
  [iisee-fix.sh](https://github.ibm.com/CASE/cloudpak-onboard-residency/blob/gh-pages/_content/data/iisee-fix.sh)
  
 
 
     
