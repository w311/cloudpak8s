---
title: Creating a scenario
weight: 700
---
- 
# Table of content
{:toc}

## Use case 1

**Order processing**

Integration capabilities for the scenario - APIC + ACE + MQ + Event Streams

![High level overview]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190917_1.png)

**Scenario**: The company ABC exposes its order processing service as an API. The API is implemented as ACE flow which posts the request to two different systems via MQ queue and ES topic.

### Download artefacts to the developer's machine

  - You can download the artefacts from here: [Artefacts](https://github.ibm.com/CASE/cloudpak-onboard-residency/tree/gh-pages/assets/integration/usecase1-artefacts)
  - Download all files including **generateSecret** subdirectory

### Prepare Event Streams

  - ICP: Workload > Helm Releases
  - Find es helm release
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_86.png)
  - Upgrade / Reuse values
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_83.png)
  - Disable message indexing
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_84.png)
  - Click Upgrade


### Create Event Streams topic

  - Open Platform Navigator: https://icp-proxy.icp4i-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud/integration
  - You can click Skip welcome
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_87.png)
  - Click on Event Streams instance
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_88.png)
  - In case of "es did not load correctly error", click on the provided "Open es" link
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_89.png)
  - ES dashboard opens, click Topics tab
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_91.png)
  - Click on Create topic
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_92.png)
  - Enter NewOrder for topic name and click Next
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_93.png)
  - Leave Partitions as 1, click Next
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_94.png)
  - Specify A Week for message retention, click Next
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_95.png)
  - Leave defaults for Replicas setting, click Create Topic
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_96.png)
  - The confirmation message appears
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_97.png)

### Extract the Event Streams connection information

  - Select Connect to this cluster
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_98.png)
  - Make note of the Bootstrap server address:
     icp-proxy.icp4i-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud:32490
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_99.png)
  - Download the PEM Certificate
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_100.png)

  - Create API Key using the section on the right
  - Enter OrdersFlow for the Application name
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_101.png)
  - Specify Produce, consume and create topics
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_102.png)
  - Select all topics
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_103.png)
  - Select all consumer groups
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_104.png)
  - Click Generate API key...
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_105.png)
  - and download the JSON file
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_106.png)

### Generate a Secret object for connecting from ACE helm release to the Event Streams instance

  - Navigate to the directory with downloaded artefacts - subdirectory **generateSecret**
  - Copy API Key from previously downloaded **es-api-key.json** to **setdbparms.txt** (Note: copy only key, not the quotes arround it)
  ![API key]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190917_2.png)
  - Override the text *<API KEY>* in **setdbparms.txt** file.
  ![API key]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190917_3.png)
  - The result should look similar to the following:
  ![API key]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190917_4.png)
  - Extract the certificate from the previously downloaded **es-cert.pem** file:
  ```
  openssl x509 -in es-cert.pem -text
  ```
  - Copy the certificate, including the lines `-----BEGIN CERTIFICATE-----` and `-----END CERTIFICATE-----` and paste it to both files: **truststore-Cert-mykey.crt** and **keystore-mykey.crt**:
  ![Certificate]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190917_5.png)
  - Navigate to the OpenShift console and select **Copy Login Command**
  ![CLI login]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190917_7.png)
  - Open terminal window and paste the command
  - Navigate to the **generateSecret** directory and run **generateSecret.sh**:
  ```
  ./generateSecrets.sh my-secret release1
  ```
  - The result should be similar to the following:
  ```
  Creating configuration secret
  kubectl create secret generic my-secret --from-file=adminPassword=./adminPassword.txt --from-file=appPassword=./appPassword.txt --from-file=truststorePassword=./truststorePassword.txt --from-file=truststoreCert-=./truststore-Cert-mykey.crt --from-file=serverconf=./serverconf.yaml  --from-file=setdbparms=./setdbparms.txt
  secret/my-secret created
  Creating users secret
  kubectl create secret generic release1-ibm-ace --from-file=adminusers=./adminusers.txt
  secret/release1-ibm-ace created  
  ```

### Configuring MQ artefacts post-deployment

  >Note: The post-deployment configuring of MQ artefacts described here can be used for demo and test environments. For the production we recommend to create a configuration secret to define the MQ configuration as a part of the Helm release or to enable the persistence for the MQ so that the configuration is preserved in case that MQ pods are recreated.     

  - Open Platform Navigator: https://icp-proxy.icp4i-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud/integration
  - Select mq
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_115.png)
  - In case of error message that the instance did not load correctly, select provided link
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_116.png)
  - The MQ Console will open
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_117.png)
  - Select queue manager and the select properties:
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_118.png)
  - On the Communication tab, find the CHLAUTH Records property and make it Disabled
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_119.png)
  - Click Save and Close
  - Click on Add widget button on top-right...
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_120.png)
  - ...and add Queues widget
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_121.png)
  - Click on Create
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_122.png)
  - Select **Local** queue type
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_123.png)
  - and give it a name **NEWORDER.MQ**
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_125.png)
  - Add Channels widget
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_126.png)
  - Click on Create to create a new channel
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_127.png)
  - ... call it **ACE.TO.MQ**, select **Server-connection** channel type
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_128.png)
  - Select the channel and click Properties
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_129.png)
  - On the **MCA tab**, for **MCA User ID** specify **mqm**
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_131.png)
  - Click Add widget again and select Authentication Information widget
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_132.png)
  - Click on the cogwheel to configure the widget
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_133.png)
  - ... and select **System objects: Show**
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_134.png)
  - Select SYSTEM.DEFAULT.AUTHINFO.IDPWOS and then click Properties
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_135.png)
  - On the User ID + password tab, for both Local connections and for Client connections specify None
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_136.png)
  - Select Save and Close
  - Select queue manager again and click on "three dots" icon, the select "Refresh security"
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_137.png)
  - Click on Connection authentication
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_138.png)

### Confirm MQ Listener port

  - Still in MQ Console, add Listeners widget
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_139.png)
  - Configure widget to see system objects
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_141.png)
  - Select **System objects: Show**
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_142.png)
  - Check the value of SYSTEM.LISTENER.TCP.1 (default is 1414)
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_143.png)
  - Navigate to OpenShift console, select **mq** project and the select Application > Services
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_144.png)
  - Select the service whose name starts with the queue manager name and has extension '-ibm-mq'
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_145.png)
  - Check the NodePort that the listener port is mapped to (in this case it is **32251**):
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_146.png)

  - We can access the listener from the outside of the cluster using the cluster proxy host name and this port.
  - However, if we are accessing the mq inside the cluster, we can use <service_name>.svc.cluster.local for the host name and target listener port (not mapped one):
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_154.png)

### Modify ACE flow

  - Start the ACE Toolkit and import project interchange file available under the previously downloaded artefacts
  - Navigate to **orders** project Resources/Subflows and open **New_Order.subflow**
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_148.png)
  - Add Http Header, MQ Output and Kafka Producer node and connect them as shown on the picture below:
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_151.png)

  - Select **Http Header** node and configure it to delete header
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_152.png)

  - Select **MQ Output** node, for Queue Name specify **NEWORDER.MQ**
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_153.png)
  - In the MQ Connect tab define
      - Connection: **MQ client connection properties**
      - Destination queue manager name: **qmtest4**
      - Queue manager host name: **qm-test4-ibm-mq.mq.svc.cluster.local**
      - Listener port number: **1414**
      - Channel name: **ACE.TO.MQ**

  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_155.png)

  - Select **Kafka producer** node.
  - Enter **NewOrder** for the topic name and previously noted bootstrap server address, in our case it is **icp-proxy.icp4i-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud:32490**
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_156.png)
  - Under Security tab select **SASL_SSL** for the Security protocol and TLSv1.2 for SSL protocol.
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190919_8.png)

  - Save the work.
  - Create BAR file. Name it **orders**
  - Add **orders** REST API, optionally select *Compile and in-line resources* and click on *Build and Save*
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190919_9.png)

### Deploy the BAR file

  - Open Platform Navigator: https://icp-proxy.icp4i-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud/integration
  - Click on ACE instance
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_161.png)
  - On the ACE dashboard navigate to the Servers tab and click Add server
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_163.png)
  - Select BAR file..
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_164.png)
  - ... and click Continue
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_165.png)
  - Copy the Content URL to the clipboard and click Configure release
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190919_10.png)

  - Helm chart opens. Click Configure.
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_167.png)
  - Enter **orders** for Helm release name, select **ace** namespace, **local-cluster** and accept license agreement:
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190920_62.png)
  - Scroll down and select **All parameters**
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_169.png)
  - Paste previously copied Content Server URL.
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190919_13.png)
  - Scroll down and for Image pull secret enter **deployer-dockercfg-wmwxh** (this secret is created during the pak installation, use OpenShift web console or **oc get secrets -n ace** command to obtain the exact name)
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190911_171.png)
  - Scroll down and enter your proxy node doman name for the Node port IP. For example:
  **icp-proxy.icp4i-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud**
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190920_66.png)
  - Enter keystore and truststore aliases and secret name as defined previously in the step for generating secrets for accessing Event Streams. In our case, the keystore alias is **mykey**, the truststore alias is **Cert-mykey** and secret name is **my-secret**
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190919_14.png)
  - Scroll down once more and disable persistence
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190919_15.png)
  - Click on the **Install** button.

  - The installation can take several minutes.
  - Navigate back to ACE dashboard, click on *Done* and wait until the server is ready.
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190919_16.png)

  - You can also navigate to the OpenShift console and select **ace** project, Applications > Pods to see the pods.
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190920_76.png)

  - Or check the pods using CLI
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190920_75.png)

  - As the result you will see the running server in the Dashoard:
  ![usecase1]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190920_78.png)

### Test the deployed ACE APIs

  - Open the Cloud Pak Navigator and select the App Connect instance
  ![Navigator]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190920_34.png)

  - Click on **ordersapi** server that we have just deployed
  ![Server]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190920_36.png)

  - The list of artefacts deployed on server appears. In our case we have only the API called **orders**. Click on it:
  ![API]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190920_37.png)

  - The page that appears shows the **REST API base URL**, link to the **OpenAPI document** (swagger) file, and list of operations. In our case there is only one POST operation and the route of that operation is **/create**:
  ![Operations]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190920_38.png)

  - Prepare a JSON file with the following content. Name it, for example **order.json**:
  ```json
  {
    "accountid": "A-10000",
    "order": {
      "orderDate": "2004-01-19T04:25:25.938Z",
      "contractId": "00000100",
      "orderDetails": [
        {
          "lineItemNumber": 1,
          "productId": "AJ1-05",
          "quantity": "20"
        }
      ]
    }
  }
  ```
  - Navigate to the terminal window and run (note that URL is built from REST API base URL and operation path **/orders**):
  ```
  curl -k -X POST http://orders.icp-proxy.icp4i-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud:30753/orders/v1/create -d @order.json
  ```  

  - The response similar to the following should be returned:
  ```
  {"accountid":"A-10000","orderid":"1632603"}
  ```

  - Open the Platform Navigator and select MQ instance
  ![Check MQ]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_122.png)

  - Select queue widget, refresh if necessary, the queue depth should be increased
  ![Check MQ]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_123.png)

  - Select *Browse messages* to see the content
  ![Check MQ]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_124.png)

  - Using the Platform Navigator, select the Event Streams instance
  ![Check ES]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_125.png)

  - Select *Topics*
  ![Check ES]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_126.png)

  - Select topic
  ![Check ES]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_127.png)

  - then check the messages
  ![Check ES]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_128.png)

### Expose the API using API Connect

  - Open once again the ACE dashboard
  ![Navigator]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190920_34.png)

  - Click on our **ordersapi** server
  ![Server]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190920_36.png)

  - And finally select our API:
  ![API]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190920_37.png)

  - As already mentioned there will be a link to the OpenAPI (swagger) document on the right side of the page:
  ![OpenAPI]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_129.png)

  - Click on it to open the document in  browser
  ![Document]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_130.png)

  - Using the browser, save the document to some directory on your local disk. The default name of the file is **swagger.json**

  - Go back to the Platform Navigator and select the API Connect instance
  ![API Connect]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_131.png)

  - Login to the API Manager
  ![API Manager]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_132.png)

  - Click on **Develop APIs and Products**
  ![APIs]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_133.png)

  - Add new API:
  ![API]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_134.png)

  - Select to create API **From existing OpenAPI service** and click **Next**
  ![API]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_135.png)

  - Select previously downloaded **swagger.json** and click **Next**
  ![JSON]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_136.png)

  - Keep default values on the next page and click **Next**
  ![Create API]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_137.png)

  - Select **Activate API** and click **Next**
  ![Activate API]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_139.png)

  - Wait until API is prepared and click **Edit API**
  ![Edit API]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_141.png)

  - Select **Assemble**:
  ![Assemble]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_143.png)

  - Run API test
  ![Test]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_144.png)

  - Select **post/create** operation:
  ![Operation]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_145.png)

  - Copy/paste the same JSON structure that you prepared in the *Test the deployed ACE APIs* step:
  ![JSON]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_149.png)

  - Click on **Invoke**
  ![Invoke]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_151.png)

  - In case of CORS error click on the provided link:
  ![CORS]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_152.png)

  - Confirm to open the page, navigate back to the test tool and click **Invoke** again
  ![Invoke]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_154.png)

  - You should receive HTTP 201 status code
  ![Response]({{ site.github.url }}/assets/img/integration/usecase1/Snip20190925_155)
