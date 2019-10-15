# Dev environment for Channel Promotion

Apply 0* to setup monio

Apply 1* to setup channels

Apply 2* to subscribe dev-qa channel

There are 2 subscriptions in this application. Each of subscriptions has its own placementrule. 

```shell
kuans-mbp:hybrid-cluster-manager-v2-chart kuan@ca.ibm.com$ kubectl get applications.app.k8s.io,subscriptions,placementrule -n demo-workspace
NAME                            AGE
application.app.k8s.io/sample   2d

NAME                                STATUS       AGE
subscription.app.ibm.com/backend    Propagated   14m
subscription.app.ibm.com/frontend   Propagated   14m

NAME                                 AGE
placementrule.app.ibm.com/backend    14m
placementrule.app.ibm.com/frontend   14m
kuans-mbp:hybrid-cluster-manager-v2-chart kuan@ca.ibm.com$ 
```

Update placementrules will change the deployment of subscriptions onto different clusters.
