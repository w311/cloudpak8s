# Dev environment for Channel Promotion

Apply 0* to setup monio. Create your own bucket in minio and update the [pathname](https://github.ibm.com/IBMPrivateCloud/hybrid-cluster-manager-v2-chart/blob/master/3.2.1-dev/channel-promotion/resources/10-channels.yaml#L14)  to it. 


Apply 1* to setup channels

Apply 2* to subscribe dev-qa channel

Use following command to promote resource from dev-qa to prod

```shell
kubectl annotate deployables.app.ibm.com sample-deploy -n dev-qa prod-ready=approved --overwrite
```
