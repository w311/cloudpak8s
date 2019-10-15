---
title: Application deployment with Multi Cloud Manager V3.2.1
weight: 300
---

- 
{:toc}

## MCM 321 Architecture

MCM 321 has restructured its object schema allowing us to decouple content from the application, but allowing the application to subscribe to a channel that publishes content from various sources. This lays the foundation for a more scalable model.

Here is a diagram illustrating the concept of how an `Application` can `Subscribe` to all `nginx` Helm Charts.

![Graphic]({{ site.github.url }}/assets/img/cp4mcm/chan_sub.png)

Here is a short video to introduce the concept of MCM Application subscription to Channels.

[The Application Channel Subscription model](https://github.ibm.com/CASE/cloudpak-onboard-residency/blob/gh-pages/assets/cp4mcm/videos/channel_subscriptions.mov)

Here is a schematic describing how we now subscribe to a channel which has connected content. Much like a TV broadcast model where households subscribe to different channels for different content streams.

![Graphic]({{ site.github.url }}/assets/img/cp4mcm/v321_architecture.png)


## Onboarding Applications into MCM V321

Here are some samples of MCM wrapped applications.

Note that there are several different Git branches to the following repository, so explore for updates.

Some applications are for V320 and other are for V321 - read the documents carefully. If you can't see a channel definition associated with the application, then it is not for MCM V321. 

[MCM wrapped application examples](https://github.ibm.com/IBMPrivateCloud/hybrid-cluster-manager-v2-chart)

### Guestbook 

There are 2 deployment models offered here.

The first allows you to deploy the 2 application components to different locations

[Deploy components to multiple targets](https://github.ibm.com/IBMPrivateCloud/hybrid-cluster-manager-v2-chart/tree/master/3.2.1-examples/guestbook-kube-subscription-separate)

The second deploys all components to the same location.

[Deploy components to a single target](https://github.ibm.com/IBMPrivateCloud/hybrid-cluster-manager-v2-chart/tree/master/3.2.1-examples/guestbook-kube-subscription).

Clone the repo and then package the Helm charts with ...

>helm package gbapp 
>helm package gbchn

Create a namespace for your channel 

>oc new-project entitlement

Install your channel chart with GUI or CLI using this template. 

>helm install gbchn -n <your_channel-name> --namespace <your_channel_namespace_name> --tls

We used the following command.

>helm install gbchn -n devchn --namespace entitlement --tls

Create a project for the Application

>oc new-project my-project

**WARNING** Don't intall gbapp to your channel namespace directly, use another one. The namespace used by the channel should be used for no other purpose. This is good practice and if you are using the same cluster as your 'hub' and 'spoke' then use a different namespace for you `helm install` than is named in the `values.yaml` file. See below how `default` is different to `my-project`

By default gbapp values enables the placement for multicluster, use following CLI to install it with placement disabled: helm install gbapp -n <your_release_name> --set channel.name=<your_channel_name>,channel.namespace=<your_channel_namespace>,placement.multicluster.enabled=false --tls

Note that if the multicluster placement is disabled, the application becomes single cluster application. Consequently all pods/services in the application are created in hub cluster directly. As a result, the application dashboard link won't be shown as no managed clusters are involved.

Install the Application chart with GUI or CLI in your project namespace. Remember you can override the variable values in `values.yaml` as in the example below. 

>helm install gbapp -n <release-name> --namespace <project_namespace> --set channel.name=<your_channel-name>,channel.namespace=<your_channel_namespace_name> --tls

This is what we used. Notice how the Helm chart representing the application is deployed into a different namespace to the channel.

>helm install gbapp -n gbapp101 --namespace my-project --set channel.name=devchn,channel.namespace=entitlement --tls

Look at the `Menu > Applications` menu and look for your `gbapp101-gbapp` application.

Explore the deployment topology 

![Graphic]({{ site.github.url }}/assets/img/cp4mcm/deployment_topology.png)

Update placement related values to redeploy application. To do this, follow `Applications > gbapp101-gbapp > Overview > Edit Deployment (small button bottom right of the screen)

Select `placement rules` from the schematic and you will be placed over the `PlacementRule` object definition in the YAML.

![Graphic]({{ site.github.url }}/assets/img/cp4mcm/PlacementRulesGUI.png)

Change and save the placment rules to select another cluster based on your needs and the target cluster associated label values.

![Graphic]({{ site.github.url }}/assets/img/cp4mcm/PlacementRulesYAML.png)

Explore the `Resources` tab and look at the `Resources by Channel` information which is telling you about the contnet delivered through the channel

![Graphic]({{ site.github.url }}/assets/img/cp4mcm/ResourcesByChannel.png)

and the `Scheduled Deployments` which is telling you the state of the deployments associated with the subscription to the channel.

![Graphic]({{ site.github.url }}/assets/img/cp4mcm/ScheduledDeployments.png)

#### Explore the deployment activity

**TIP** Remember the `kubectl api-resources` command

Look for any deployable with `'gb` in the name

>oc get deployables.app.ibm.com --all-namespaces |grep -i gb

```
my-project   gbapp102-gbapp-guestbook-deployable           Subscription    app.ibm.com/v1alpha1   5d        Propagated
channel       gbchn-gbchn-frontend                          Deployment      apps/v1                5d        
channel       gbchn-gbchn-redismaster                       Deployment      apps/v1                5d        
channel       gbchn-gbchn-redismasterservice                Service         v1                     5d        
channel       gbchn-gbchn-redisslave                        Deployment      apps/v1                5d        
channel       gbchn-gbchn-redisslaveservice                 Service         v1                     5d        
channel       gbchn-gbchn-service                           Service         v1                     5d        
default       gbapp101-gbapp-deployable                     Subscription    app.ibm.com/v1alpha1   5d        Propagated
default       gbapp101-gbapp-redismaster-deployable         Subscription    app.ibm.com/v1alpha1   5d        Propagated
mcm           gbapp101-gbapp-deployable-hl5k9               Subscription    app.ibm.com/v1alpha1   5d        Failed
mcm           gbapp101-gbapp-redismaster-deployable-ztdnm   Subscription    app.ibm.com/v1alpha1   5d        Failed
mcm           gbapp102-gbapp-guestbook-deployable-z2pt2     Subscription    app.ibm.com/v1alpha1   5d        Deployed
```

Note that there is the deployable into our `my-project` namespace but the `PlacementPolicy` has placed the applciation artifacts in the `mcm` namespace.

Investigate more with 

>oc get deployables.app.ibm.com gbapp102-gbapp-guestbook-deployable -n my-project -o yaml

#### Cleanup

Delete application helm release to deregister application 

>helm delete <release-name> --purge --tls

Delete channel helm release to clean up channel 

>helm delete <channel-name> --purge --tls

### QuoteOfTheDay

Another sample [Application built by James Conallen](https://gitlab.169.60.97.238.nip.io/users/jconallen/contributed)

[QuoteOfTheDay](https://gitlab.169.60.97.238.nip.io/quote-of-the-day)

#### Application Components

[qod-api](https://gitlab.169.60.97.238.nip.io/quote-of-the-day/qod-api)

[qod-db](https://gitlab.169.60.97.238.nip.io/quote-of-the-day/qod-db)

[qod-web](https://gitlab.169.60.97.238.nip.io/quote-of-the-day/qod-web)

#### Packaged Helm Charts

[api](https://gitlab.169.60.97.238.nip.io/quote-of-the-day/qod-api/blob/master/deployment/qod-api-1.0.0.tgz)

>wget https://gitlab.169.60.97.238.nip.io/quote-of-the-day/qod-api/blob/master/deployment/qod-api-1.0.0.tgz

[db](https://gitlab.169.60.97.238.nip.io/quote-of-the-day/qod-db/blob/master/deployment/qod-db-1.0.0.tgz)

>wget https://gitlab.169.60.97.238.nip.io/quote-of-the-day/qod-db/blob/master/deployment/qod-db-1.0.0.tgz

[web](https://gitlab.169.60.97.238.nip.io/quote-of-the-day/qod-web/blob/master/deployment/qod-web-1.0.0.tgz)

>wget https://gitlab.169.60.97.238.nip.io/quote-of-the-day/qod-web/blob/master/deployment/qod-web-1.0.0.tgz

#### Load Helm Charts

Load all of these HELM CHarts into the local Helm Repository

>cloudctl catalog load-chart --archive qod-api-1.0.0.tgz

>cloudctl catalog load-chart --archive qod-db-1.0.0.tgz

>cloudctl catalog load-chart --archive qod-web-1.0.0.tgz

#### The scenario

Our `Application` is going to `Subscribe` to our `Channel` that is connected to our local Helm Repository, and deploy a Helm Chart defined workload.

#### Connecting a `Channel` to the local Helm Repository.

Here is the information that I used about [connecting a channel to a Helm Repository](https://github.ibm.com/IBMPrivateCloud/roadmap/issues/31789])

First we need to get the details of the Helm Repository.

>cloudctl catalog repos

```
Name                   URL                                                                                                                               Local   
ibm-charts             https://raw.githubusercontent.com/IBM/charts/master/repo/stable/                                                                  false   
local-charts           https://icp-console.mcmresidency1-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud:443/helm-repo/charts   true   
mgmt-charts            https://icp-console.mcmresidency1-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud:443/mgmt-repo/charts   true   
ibm-charts-public      https://registry.bluemix.net/helm/ibm/                                                                                            false   
ibm-community-charts   https://raw.githubusercontent.com/IBM/charts/master/repo/community/                                                               false   
ibm-entitled-charts    https://raw.githubusercontent.com/IBM/charts/master/repo/entitled/  
```

We will use the `local-charts` Repository

We need to create a `channel` for this repository

```
apiVersion: app.ibm.com/v1alpha1
kind: Channel
metadata:
  name: qotdchn
  namespace: entitlement
spec:
  type: HelmRepo
  pathname: https://icp-console.mcmresidency1-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud:443/helm-repo/charts
  configRef:
    name: repo-config
  secretRef:
    name: repo-secret
```

>oc apply -f channel.yaml 

```
channel.app.ibm.com/qotdchn created
```
>oc get channels.app.ibm.com -n entitlement

```
NAME      TYPE       PATHNAME                                                                                                                          AGE
qotdchn   HelmRepo   https://icp-console.mcmresidency1-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud:443/helm-repo/charts   2m
```

The `ConfigMap` referenced by the `configRef` must be created on the hub and the managed-cluster in the same namespace as the channel. The same is true for the `secretRef`. These 2 references could also specify their own namespace for these Custom Resources.

>oc project entitlement

```
Now using project "entitlement" on server "https://c100-e.us-east.containers.cloud.ibm.com:32653".
```

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: repo-config
  namespace: entitlement
data:
  insecureSkipVerify: "true"
```

>oc apply -f configmap.yaml

```
configmap/repo-config created
```

The `configMap` resource only supports one parameter for the time being: `insecureSkipVerify`. If true the hostname will be not be verifed.

Encode your Helm Repository credentials before we add then to the `Secret`

>echo -n 'admin' | openssl base64

`
YWRtaW4=
`
We will need a secret to hold the Helm Repository credentials

```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: repo-secret
  namespace: entitlement
data:
  user: uid (base64)
  password: pwd (base64)
```

So with our credentials it looks like ..

```
data:
  user: YWRtaW4=
  password: YWRtaW4=
```

>oc apply -f secret.yaml 

```
secret/repo-secret created
```

Check out your newly created secret.

>oc describe secret repo-secret -n entitlement

```
Name:         repo-secret
Namespace:    entitlement
Labels:       app.ibm.com/serving-channel=true
Annotations:  
Type:         Opaque

Data
====
password:  5 bytes
user:      5 bytes
```


Now that we have defined a `Channel` that is connected to a Helm Repository, we need to define a `Subscription` to this `Channel` that will be used by our `Application`.

```
kind: Subscription
metadata:
  annotations:
    tillerVersion: 2.4.0
  name: qotdsub
  namespace: default
  labels:
    app: qotdapp
spec:
  channel: entitlement/qotdchn
  name: qod-web
  packageFilter:
    annotations:
      tillerVersion: 2.4.0
    version: "1.0.0"
  packageOverrides:
  - packageName: qod-web
    packageOverrides:
    - path: spec.values
      value: |
          valueName1: value 1
          valueName2: value 2
```

The `spec.name` defines the helm-chart to deploy and this field is mandatory.
As a helm-repo can contains multiple helm-chart with the same name but with different versions, the `spec.packageFilter` contains filters to select a subset of versions (tillerVersion,version or digest). if still multiple versions are eligible after the filtering, the higher version will be taken.

The `spec.packageOverrides` allows you to provide values for the helm-chart. The `spec.packageOverrides.packageName` must be the same as the `spec.name`

The subscription will be propagated to the managed cluster. The subscription controller running on the end-point will start to process the subscription, read the channel to get the `configRef` and `secretRef`, connect to the helm-repo to download the index.yaml and then create a `helmrelease` CR.

The `helmrelease` CR will be processed by the helm-crd controller and the helm-chart will be deployed.

The `Subscription` is bound to the `Application` as both use 'app: qotdapp' in their label definition, and the `Subscription` binds to the `Channel` with 'channel: entitlement/qotdchn'

Finally we need a `PlacmentRule` that defines where the `deployables` will be installed.

```
apiVersion: app.ibm.com/v1alpha1
kind: PlacementRule
metadata:
  name: qotdrule
  labels:
    app: qotdapp
spec:
  clusterReplicas: 1
  clusterLabels:
    matchLabels:
      name: mcm
```

>oc apply -f placementrule.yaml 
```
placementrule.app.ibm.com/qotdrule created
```

There is more work to do here to pretty up the process with Helm CHarts, `values.yaml` files and value lookups. But this should be enough now to show you the process.

Now use the GUI and command line calls to investigate the progress of the Helm Chart deployment.

Look for our `qotdapp` in the application summary.

![Graphic]({{ site.github.url }}/assets/img/cp4mcm/qotdapp.png)

Now look at the details of the resources associated with the `Application`

![Graphic]({{ site.github.url }}/assets/img/cp4mcm/qotdapp_detail.png)

#### Debugging a deployment

Look at the 

- Log of the subscription controller
- Log of the helm-crd controller.

Both will be running in the kube-system namespace..

#### Source materials

![Graphic]({{ site.github.url }}/assets/img/cp4mcm/app_sub_helm.png)

We have published these assets that we use under the following link.

[YAML](https://github.ibm.com/CASE/cloudpak-onboard-residency/tree/gh-pages/assets/cp4mcm/samples/myapp/yaml)

#### Packaging these MCM Objects in Helm Charts

An example refinement.

This work is not complete, but contains a Helm chart for the `Channel` and another for the `Application`, and is looking to deploy `nginx` through `Channel` `Subscription` to Helm Repositories.

**NOTE** Update the label schema in the following objects to reflect `nginx` rather than `qotd`

[Channel Helm Chart](https://github.ibm.com/CASE/cloudpak-onboard-residency/tree/gh-pages/assets/cp4mcm/samples/myapp/qotdchn)


```
tree
.
├── Chart.yaml
├── templates
│   ├── NOTES.txt
│   ├── _helpers.tpl
│   └── channel.yaml
└── values.yaml

1 directory, 5 files
```

[Application Helm Chart](https://github.ibm.com/CASE/cloudpak-onboard-residency/tree/gh-pages/assets/cp4mcm/samples/myapp/qotdapp)

```
tree
.
├── Chart.yaml
├── templates
│   ├── NOTES.txt
│   ├── _helpers.tpl
│   ├── application.yaml
│   ├── placement.yaml
│   └── subscription.yaml
└── values.yaml

1 directory, 7 files
```

First we need to define a `channel` in `./qotdchn/templates/channel.yaml` which is going to provide a link to a Helm repository. This channel is defined in a namespace. 

```
macbook:templates rhine$ cat channel.yaml 
apiVersion: v1
kind: Namespace
metadata:
  name: entitlement
spec:

---
apiVersion: app.ibm.com/v1alpha1
kind: Channel
metadata:
  name: qotd
  namespace: entitlement
spec:
  type: HelmRepo
  pathname: https://kubernetes-charts.storage.googleapis.com
```
See the `qotd` example above for using `ConfigMaps` and `Secrets` for authentiacation against Helm Repositories.

Create the channel 

>oc apply -f channel.yaml

Now we define the `application` in `./qotdapp/templates/application.yaml`. Note that the `application` includes a `componentKinds:` of `Subscription`

```
apiVersion: app.k8s.io/v1beta1
kind: Application
metadata:
  namespace: default
  name: qotdapp
  labels:
    app: qotdapp
spec:
  selector:
    matchExpressions:
    - key: app
      operator: In
      values:
      - qotdapp
  componentKinds:
  - group: app.ibm.com
    kind: Subscription
  - group: core
    kind: Pods
  - group: core
    kind: Service
  - group: apps
    kind: Deployment
  - group: apps
    kind: StatefulSet
```

> oc apply -f application.yaml

Now we have to subscribe the `application` to a `channel` as in `./qotdapp/templates/subscription.yaml`. This is a `subscription` definition that is used by the `application`.

```
apiVersion: app.ibm.com/v1alpha1
kind: Subscription
metadata:
  name: qotdsub
  labels:
    app: qotdapp
spec:
  channel: entitlement/qotd
  name: nginx-ingress
  placement:
    placementRef:
      name: qotdrule
      kind: PlacementRule
      group: app.ibm.com
  overrides:
  - clusterName: "/"
    clusterOverrides:
    - path: "metadata.namespace"
      value: default
```
> oc apply -f subscription.yaml

Finally, we have the `PlacementRule` that links the application to a cluster as in `./qotdapp/templates/placement.yaml`

```
apiVersion: app.ibm.com/v1alpha1
kind: PlacementRule
metadata:
  name: qotdrule
  labels:
    app: qotdapp
spec:
  clusterReplicas: 1
  clusterLabels:
    matchLabels:
      name: mcm
```      

> oc apply -f placement.yaml

We could have packaged up these 2 charts and loaded them into the catalog, but the set of `apply` commands above has the same effect.

```
oc create -f configmap.yaml 
oc create -f secret.yaml 
oc create -f channel.yaml 
oc create -f subscription.yaml 
oc create -f application.yaml 
oc create -f placementrule.yaml 

```  
#### Tracking the deployment

>oc project app-project

```
Now using project "app-project" on server "https://c100-e.us-east.containers.cloud.ibm.com:32653".
```

>oc get placementrule

```
NAME             AGE
qotdrule         1h
```
>oc get placementrule qotdrule -o yaml

See that `status.decisions.clusterName` and `status.decisions.clusterNamespace` values have been chosen to deploy this workload in the `mcm` namespace on the `mcm` labeled cluster.

```
apiVersion: app.ibm.com/v1alpha1
kind: PlacementRule
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"app.ibm.com/v1alpha1","kind":"PlacementRule","metadata":{"annotations":{},"labels":{"app":"qotdapp"},"name":"qotdrule","namespace":"app-project"},"spec":{"clusterLabels":{"matchLabels":{"name":"mcm"}},"clusterReplicas":1}}
    mcm.ibm.com/user-group: c3lzdGVtOmF1dGhlbnRpY2F0ZWQ6b2F1dGgsc3lzdGVtOmF1dGhlbnRpY2F0ZWQ=
    mcm.ibm.com/user-identity: SUFNI2FuZHlyb2JAY2EuaWJtLmNvbQ==
  creationTimestamp: 2019-09-12T14:45:01Z
  generation: 1
  labels:
    app: qotdapp
  name: qotdrule
  namespace: app-project
  resourceVersion: "5528452"
  selfLink: /apis/app.ibm.com/v1alpha1/namespaces/app-project/placementrules/qotdrule
  uid: e680631c-d56b-11e9-8f6d-c6b6dcb48a81
spec:
  clusterLabels:
    matchLabels:
      name: mcm
  clusterReplicas: 1
status:
  decisions:
  - clusterName: mcm
    clusterNamespace: mcm

```

Check the `clusterName` and `ClusterNamespace` values under `decisions`. In our case we are deploying to a cluster named `mcm`

Let's look at the `Subscription` object instance

>oc get subscription
```
NAME                       STATUS       AGE
qotdsub                    Propagated   2h
```
>oc get subscription qotdsub

```
NAME      STATUS       AGE
qotdsub   Propagated   2h
```

>oc get subscription qotdsub -o yaml

Some lines deleted from the command output below....

```
apiVersion: app.ibm.com/v1alpha1
kind: Subscription
metadata:
  annotations:
    app.ibm.com/deployables: entitlement/qotd-locust-1.1.1,entitlement/qotd-sugarcrm-1.0.7,entitlement/qotd-prometheus-rabbitmq-exporter-0.5.2,entitlement/qotd-dex-2.2.0,entitlement/qotd-hlf-peer-1.2.10,entitlement/qotd-msoms-0.2.0,entitlement/qotd-node-problem-detector-1.5.2,entitlement/qotd-phpbb-6.2.1,entitlement/qotd-kubedb-nt/qotd-metabase-0.8.0,entitlement/qotd-mongodb-replicaset-3.9.6,entitlement/qotd-sysdig-1.4.15
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"app.ibm.com/v1alpha1","kind":"Subscription","metadata":{"annotations":{},"labels":{"app":"qotdapp"},"name":"qotdsub","namespace":"app-project"},"spec":{"channel":"entitlement/qotd","name":"nginx-ingress","overrides":[{"clusterName":"/","clusterOverrides":[{"path":"metadata.namespace","value":"default"}]}],"placement":{"placementRef":{"group":"app.ibm.com","kind":"PlacementRule","name":"qotdrule"}}}}
    mcm.ibm.com/user-group: c3lzdGVtOmF1dGhlbnRpY2F0ZWQ6b2F1dGgsc3lzdGVtOmF1dGhlbnRpY2F0ZWQ=
    mcm.ibm.com/user-identity: SUFNI2FuZHlyb2JAY2EuaWJtLmNvbQ==
  creationTimestamp: 2019-09-12T14:34:11Z
  generation: 4
  labels:
    app: qotdapp
  name: qotdsub

spec:
  channel: entitlement/qotd
  name: nginx-ingress
  overrides:
  - clusterName: /
    clusterOverrides:
    - path: metadata.namespace
      value: default
  placement:
    placementRef:
      kind: PlacementRule
      name: qotdrule
  source: ""
  sourceNamespace: ""
status:
  lastUpdateTime: 2019-09-12T16:41:44Z
  phase: Propagated
  statuses:
    mcm:
      packages:
        qotd-nginx-ingress-1.20.0:
          lastUpdateTime: 2019-09-12T16:41:40Z
          phase: Subscribed
          resourceStatus:
            lastUpdateTime: 2019-09-12T14:55:15Z
            status: Success
```

Now let us check out the `Deployables`

>oc get deployables.app.ibm.com -n mcm

```
NAME                                          TEMPLATE-KIND   TEMPLATE-APIVERSION    AGE       STATUS
qotdsub-deployable-45hhz                      Subscription    app.ibm.com/v1alpha1   2h        Deployed
```

>oc get deployables.app.ibm.com qotdsub-deployable-45hhz -n mcm 

```
NAME                       TEMPLATE-KIND   TEMPLATE-APIVERSION    AGE       STATUS
qotdsub-deployable-45hhz   Subscription    app.ibm.com/v1alpha1   2h        Deployed
```

Check out the details of the deployment results (not all lines included!)

>oc get deployables.app.ibm.com qotdsub-deployable-45hhz -n mcm -o yaml

```
kind: Deployable
metadata:
  annotations:
    app.ibm.com/hosting-deployable: app-project/qotdsub-deployable
  generateName: qotdsub-deployable-
  generation: 40
  labels:
    hosting-deployable-name: qotdsub-deployable
  name: qotdsub-deployable-45hhz
  namespace: mcm
  selfLink: /apis/app.ibm.com/v1alpha1/namespaces/mcm/deployables/qotdsub-deployable-45hhz
spec:
  template:
    kind: Subscription
    metadata:
      annotations:
        app.ibm.com/deployables: entitlement/qotd-prometheus-operator-6.11.0,entitlement/qotd-vault-operator-0.1.1,entitlement/qotd-rethinkdb-1.0.0,entitlement/qotd-newrelic-infrastructure-0.13.8,entitlement/qotd-opa-0.17.0,entitlement/qotd-stolon-1.1.2,entitlement/qotd-telegraf-1.1.5,entitlement/qotd-gcloud-endpoints-0.1.2,entitlement/qotd-searchlight-0.3.3
        app.ibm.com/hosting-subscription: app-project/qotdsub
        kubectl.kubernetes.io/last-applied-configuration: |
          {"apiVersion":"app.ibm.com/v1alpha1","kind":"Subscription","metadata":{"annotations":{},"labels":{"app":"qotdapp"},"name":"qotdsub","namespace":"app-project"},"spec":{"channel":"entitlement/qotd","name":"nginx-{"placementRef":{"group":"app.ibm.com","kind":"PlacementRule","name":"qotdrule"}}}}
        mcm.ibm.com/user-group: c3lzdGVtOmF1dGhlbnRpY2F0ZWQ6b2F1dGgsc3lzdGVtOmF1dGhlbnRpY2F0ZWQ=
      labels:
        app: qotdapp
      name: qotdsub
      namespace: default
    spec:
      channel: entitlement/qotd
      name: nginx-ingress
      source: ""
      sourceNamespace: ""
    status:
      lastUpdateTime: null
status:
  phase: Deployed
  resourceStatus:
    phase: Subscribed
    statuses:
      /:
        packages:
          qotd-nginx-ingress-1.20.0:
            lastUpdateTime: 2019-09-12T17:09:45Z
            phase: Failed
            reason: 'admission webhook "user-check.ibm.com" denied the request: Only
              cluster-admins can make requests for HelmRelease kind'
            resourceStatus:
              lastUpdateTime: 2019-09-12T14:55:15Z
              status: Success
```

We have an authentication issue to resole here to allow us to connct to the Helm Respository - later my friends.

Lets' look at the application `placementrule`

>oc get placementrule qotdrule

```
NAME       AGE
qotdrule   2h
```

Here are details of the `Application` `PlacementRule` object. (some details removed!). Look at the `clusterLabels:` and the `decisions:` stanzas.

>oc get placementrule qotdrule -o yaml

```
kind: PlacementRule
metadata:
  annotations:
  creationTimestamp: 2019-09-12T14:45:01Z
  generation: 1
  labels:
    app: qotdapp
  name: qotdrule
  namespace: app-project
spec:
  clusterLabels:
    matchLabels:
      name: mcm
  clusterReplicas: 1
status:
  decisions:
  - clusterName: mcm
    clusterNamespace: mcm
```

MCM has decided to deploy the application deployable to the cluster named `mcm`.

For interest, you can display the Helm Repo that is associated with the `entitlement` channel.

>oc get channel -n entitlement

```
NAME      TYPE       PATHNAME                                           AGE
qotd      HelmRepo   https://kubernetes-charts.storage.googleapis.com   3h
```

#### Explore the MCM User interfaces

Here we can see resources available through a channel and details of the deployments scheduled through subscription relationships between `Applications` and `Channels`.

![Graphic]({{ site.github.url }}/assets/img/cp4mcm/mcm_resource_overview.png)

#### Sample Objects

[Channel](https://github.ibm.com/IBMMulticloudPlatform/channel/blob/master/config/samples/qa_helmrepo_channel.yaml)

[Subscription](https://github.ibm.com/IBMMulticloudPlatform/subscription/blob/master/config/samples/helm_sub.yaml)


### Stocktrader

[Yu Bing Jiao](https://hub.docker.com/r/yubingjiaocn/portfolio)


### Other Sample Applications

[MCM wrapped application examples](https://github.ibm.com/IBMPrivateCloud/hybrid-cluster-manager-v2-chart)

## Extra materials

[European Tech Sales Q3 training](https://ibm.box.com/s/hdg3wvx02r3v8cb9hhwxq1u2vb4v4lq4)

## Exploring the K8S MCM schema

You can use `kubectl` to explore the K8S schema and help you with manifest object definitions.

Let's start with `kubectl api-resources|grep -i application`

You will see here that there are 2 x `Applications` objects defined. One comes from core K8S, and the other comes from the `ArgoCD` that we installed from the MCM Optional Components tar file.

```
kubectl api-resources|grep -i application
applications            app.k8s.io                            true         Application
applications     app    argoproj.io                           true         Application
```

If we look for MCM related objects, we see a mix of application and policy related objects with their full name in column 1 and any associated abbreviation in the next column.
```
kubectl api-resources|grep -i mcm|grep -i deploy

deployableoverrides   do   mcm.ibm.com                        true         DeployableOverride
deployables                mcm.ibm.com                        true         Deployable
```

Now you can use the `explain` argument to explore some more.

```
kubectl explain deployables
.
KIND:     Deployable
VERSION:  mcm.ibm.com/v1alpha1
.
FIELDS:
.
   spec	<Object>
     Spec of Node Template
.

```
and deeper ...

```
kubectl explain deployables.spec

KIND:     Deployable
VERSION:  mcm.ibm.com/v1alpha1
.
   deployer	<Object>
     Deployer describes how to deploy the target node
.
```

until we get to ...

```
explain deployables.spec.deployer.helm
.
   chartURL	<string>
     Chart url
.     
   valuesURL	<string>
     ValuesURL url to a file contains value
.
```

These 2 variables are what I mentioned earlier, and allow us to change the Helm chart and its values without repackaging and uploading the MCM wrapper chart.
