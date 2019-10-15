# Bare Minimum Channel/Subscription on Standalone Openshift 3.11 Environment

This example works without other ICP/MCM components.

Use following steps to stand the environment.

Step 1: Apply all the yaml files in `resource` start with `0` to get the demo environment. `kubectl apply -f ./0*`

Step 2: Wait until all controllers are running. `kubectl get deploy.app -n ibm-apps`

Step 3: Apply all the yaml files in `resource` start with `1` to configure channel and subscription `kubectl apply -f ./1*`

Step 4: Check Subscription for update `kubectl get subscriptions -n demo-workspace sample -o yaml`

## What's included:

1. Create `ibm-apps` namespace for controllers, setup rbac, and image pull secret. (rbac.yaml)
2. Install required CRDs to facilitate controllers
3. Create `dev` channel and namespace and put a deployment and a configmap Deployable inside it
4. Create `dem-oworkspace` namespace and put Subscription and Application in it

## What's not included:

1. Application controller, Deployable controller, 
2. ObjectStore/HelmRepo channel example

## Deployed Example:

ClusterRole, RoleBindings:
```shell
root@icp1x12:~/openshift/4.1/resources# kubectl get clusterrole,clusterrolebindings | grep ibm-multicluster
clusterrole.authorization.openshift.io/ibm-multicluster

clusterrolebinding.authorization.openshift.io/ibm-multicluster      /ibm-multicluster          ibm-apps/ibm-multicluster                                                          
```

Controller:

```shell
root@icp1x12:~/openshift/4.1/resources# kubectl get deploy,sa -n ibm-apps
NAME                                          DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.extensions/subscription-operator   1         1         1            1           2d

NAME                              SECRETS   AGE
serviceaccount/ibm-multicluster   2         1d
root@icp1x12:~/openshift/4.1/resources# 
```

Channel:

```shell
root@icp1x12:~/openshift/4.1/resources# kubectl get deployables.app.ibm.com,channel -n dev
NAME                                      TEMPLATE-KIND   TEMPLATE-APIVERSION   AGE   STATUS
deployable.app.ibm.com/sample-configmap   ConfigMap       v1                    1h    
deployable.app.ibm.com/sample-deploy      Deployment      apps/v1               1h    

NAME                      TYPE        PATHNAME   AGE
channel.app.ibm.com/dev   Namespace   dev        1h
root@icp1x12:~/openshift/4.1/resources# 
```

Subscription and deployed resource:

```shell
root@icp1x12:~/openshift/4.1/resources# kubectl get subscriptions,deploy,configmap -n demo-workspace
NAME                              STATUS       AGE
subscription.app.ibm.com/sample   Subscribed   1m

NAME                                      DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.extensions/sample-deployment   1         1         1            0           1m

NAME                         DATA   AGE
configmap/sample-configmap   1      1m

```

Subscription Status:

```shell
root@icp1x12:~/openshift/4.1/resources# kubectl get subscriptions -n demo-workspace sample -o yaml
apiVersion: app.ibm.com/v1alpha1
kind: Subscription
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"app.ibm.com/v1alpha1","kind":"Subscription","metadata":{"annotations":{},"labels":{"purpose":"sample-demo"},"name":"sample","namespace":"demo-workspace"},"spec":{"channel":"dev/dev"}}
  creationTimestamp: "2019-08-18T17:35:41Z"
  generation: 1
  labels:
    purpose: sample-demo
  name: sample
  namespace: demo-workspace
  resourceVersion: "551568"
  selfLink: /apis/app.ibm.com/v1alpha1/namespaces/demo-workspace/subscriptions/sample
  uid: 99ba3303-c1de-11e9-9faf-0eea60286832
spec:
  channel: dev/dev
status:
  lastUpdateTime: "2019-08-18T17:38:12Z"
  phase: Subscribed
  statuses:
    /:
      packages:
        sample-configmap:
          lastUpdateTime: "2019-08-18T17:38:12Z"
          phase: Subscribed
        sample-deploy:
          lastUpdateTime: "2019-08-18T17:37:21Z"
          phase: Subscribed
          resourceStatus:
            conditions:
            - lastTransitionTime: "2019-08-18T17:35:49Z"
              lastUpdateTime: "2019-08-18T17:37:18Z"
              message: ReplicaSet "sample-deployment-67594d6bf6" has successfully
                progressed.
              reason: NewReplicaSetAvailable
              status: "True"
              type: Progressing
            - lastTransitionTime: "2019-08-18T17:37:19Z"
              lastUpdateTime: "2019-08-18T17:37:19Z"
              message: Deployment does not have minimum availability.
              reason: MinimumReplicasUnavailable
              status: "False"
              type: Available
            observedGeneration: 1
            replicas: 1
            unavailableReplicas: 1
            updatedReplicas: 1

```
