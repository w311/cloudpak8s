# Dev environment for Channel Promotion

Apply 0* to setup monio

Apply 1* to setup channels

Apply 2* to subscribe dev-qa channel

Find substatus following
```shell
Kuans-MacBook-Pro:placementrule kuan@ca.ibm.com$ kubectl get subscriptions -n demo-workspace -o yaml

...

  status:
    lastUpdateTime: 2019-08-27T01:58:12Z
    phase: Propagated
    statuses:
      shanghai: {}
      toronto: {}
      washdc:
        packages:
          sample-configmap-110:
            lastUpdateTime: 2019-08-27T01:54:01Z
            phase: Subscribed
          sample-deploy-110:
            lastUpdateTime: 2019-08-27T01:58:11Z
            phase: Subscribed
            resourceStatus:
              conditions:
              - lastTransitionTime: 2019-08-27T01:58:02Z
                lastUpdateTime: 2019-08-27T01:58:02Z
                message: Deployment does not have minimum availability.
                reason: MinimumReplicasUnavailable
                status: "False"
                type: Available
              - lastTransitionTime: 2019-08-27T01:58:02Z
                lastUpdateTime: 2019-08-27T01:58:02Z
                message: ReplicaSet "sample-deployment-6dd86d77d" is progressing.
                reason: ReplicaSetUpdated
                status: "True"
                type: Progressing
              observedGeneration: 1
              replicas: 1
              unavailableReplicas: 1
              updatedReplicas: 1

```

Apply 3* with updated deployment deployable, wait a while and find deploy package changed to 120. 

```shell
Kuans-MacBook-Pro:placementrule kuan@ca.ibm.com$ kubectl get subscriptions -n demo-workspace -o yaml

...

  status:
    lastUpdateTime: 2019-08-27T02:00:33Z
    phase: Propagated
    statuses:
      shanghai: {}
      toronto: {}
      washdc:
        packages:
          sample-configmap-110:
            lastUpdateTime: 2019-08-27T01:58:33Z
            phase: Subscribed
          sample-deploy-120:
            lastUpdateTime: 2019-08-27T02:00:33Z
            phase: Subscribed
            resourceStatus:
              conditions:
              - lastTransitionTime: 2019-08-27T02:00:24Z
                lastUpdateTime: 2019-08-27T02:00:24Z
                message: Deployment does not have minimum availability.
                reason: MinimumReplicasUnavailable
                status: "False"
                type: Available
              - lastTransitionTime: 2019-08-27T02:00:24Z
                lastUpdateTime: 2019-08-27T02:00:24Z
                message: ReplicaSet "sample-deployment-6dd86d77d" is progressing.
                reason: ReplicaSetUpdated
                status: "True"
                type: Progressing
              observedGeneration: 1
              replicas: 3
              unavailableReplicas: 3
              updatedReplicas: 3

```