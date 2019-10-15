# ObjectBucket Channel/Subscription on Standalone Openshift 3.11 Environment

This example works without other ICP/MCM components.

In this example, Manual Step is required. Use following steps to stand the environment.

Step 1: Apply all the yaml files in `resource` start with `0` to get the demo environment. `kubectl apply -f ./0*`

Step 2: Wait until all controllers are running. `kubectl get deploy.app -n ibm-apps`

Step 3: Do ManualSteps to create Bucket and configure your channel

Step 4: Apply all the yaml files in `resource` start with `1` to configure channel and subscription `kubectl apply -f ./1*`

Step 5: Check Subscription for update `kubectl get subscriptions -n demo-workspace sample -o yaml`


## What's included:

0. Install minio as Object Store, if you bring your own Object Store, you can skip the minio.yaml
1. Create `ibm-apps` namespace for controllers, setup rbac, and image pull secret. (rbac.yaml)
2. Install required CRDs to facilitate controllers
3. Create `dev` channel and namespace and put a deployment and a configmap Deployable inside it
4. Create `demo-workspace` namespace and put Subscription and Application in it

## Manual Steps:

Setup ObjectStore Bucket. If you are using minio provided by this example, follow the steps below:

1. find out the access point of your minio. It is installed with NodePort.

```shell
root@icp1x12:~/workspace/csdemo/objectbucket/resources# kubectl get services -n ibm-apps
NAME    TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
minio   NodePort   172.30.164.243   <none>        9000:31612/TCP   1h
root@icp1x12:~/workspace/csdemo/objectbucket/resources# 
```

2. In your browser, loging to that minio `http://<your_os_access_ip_or_dn>:31612` using following credentials (you can decode them from secret)

```shell
AccessKey: AKIAIOSFODNN7EXAMPLE
SecretKey: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

3. Create a Bucket in the minio (e.g. demo-simple)

4. Update the Channel.spec.pathname (in qa-channel.yaml) with the bucket link you just created.

## What's not included:

1. Application controller, Deployable controller, 
2. HelmRepo channel example

## Deployed Example:

minior

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
root@icp1x12:~/workspace/csdemo/objectbucket/resources# kubectl get deployable,channel -n qa
NAME                                      TEMPLATE-KIND   TEMPLATE-APIVERSION   AGE   STATUS
deployable.app.ibm.com/sample-configmap   ConfigMap       v1                    32m   
deployable.app.ibm.com/sample-deploy      Deployment      apps/v1               1h    

NAME                     TYPE           PATHNAME                                                              AGE
channel.app.ibm.com/qa   ObjectBucket   http://moral-alien-master.purple-chesterfield.com:31612/demo-simple   1h
root@icp1x12:~/workspace/csdemo/objectbucket/resources# 
```

Subscription and deployed resource:

```shell
root@icp1x12:~/workspace/csdemo/objectbucket/resources# kubectl get subscriptions,deploy,configmap -n demo-workspace
NAME                              STATUS       AGE
subscription.app.ibm.com/sample   Subscribed   28m

NAME                                      DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.extensions/sample-deployment   1         1         1            0           28m

NAME                         DATA   AGE
configmap/sample-configmap   1      28m
root@icp1x12:~/workspace/csdemo/objectbucket/resources# 
```

Subscription Status:

```shell
root@icp1x12:~/workspace/csdemo/objectbucket/resources# kubectl get subscriptions -n demo-workspace sample -o yaml
apiVersion: app.ibm.com/v1alpha1
kind: Subscription
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"app.ibm.com/v1alpha1","kind":"Subscription","metadata":{"annotations":{},"labels":{"purpose":"sample-demo"},"name":"sample","namespace":"demo-workspace"},"spec":{"channel":"qa/qa"}}
  creationTimestamp: "2019-08-18T20:48:25Z"
  generation: 1
  labels:
    purpose: sample-demo
  name: sample
  namespace: demo-workspace
  resourceVersion: "582127"
  selfLink: /apis/app.ibm.com/v1alpha1/namespaces/demo-workspace/subscriptions/sample
  uid: 862c4d16-c1f9-11e9-9faf-0eea60286832
spec:
  channel: qa/qa
status:
  lastUpdateTime: "2019-08-18T21:16:04Z"
  phase: Subscribed
  statuses:
    /:
      packages:
        sample-configmap:
          lastUpdateTime: "2019-08-18T21:16:04Z"
          phase: Subscribed
        sample-deploy:
          lastUpdateTime: "2019-08-18T21:12:43Z"
          phase: Subscribed
          resourceStatus:
            conditions:
            - lastTransitionTime: "2019-08-18T20:48:32Z"
              lastUpdateTime: "2019-08-18T20:48:32Z"
              message: Deployment does not have minimum availability.
              reason: MinimumReplicasUnavailable
              status: "False"
              type: Available
            - lastTransitionTime: "2019-08-18T20:58:33Z"
              lastUpdateTime: "2019-08-18T20:58:33Z"
              message: ReplicaSet "sample-deployment-67594d6bf6" has timed out progressing.
              reason: ProgressDeadlineExceeded
              status: "False"
              type: Progressing
            observedGeneration: 1
            replicas: 1
            unavailableReplicas: 1
            updatedReplicas: 1
root@icp1x12:~/workspace/csdemo/objectbucket/resources# 
```
