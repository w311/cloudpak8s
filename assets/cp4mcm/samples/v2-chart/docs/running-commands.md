# Running HCM-v2 commands

Once you install the chart, you can run the following commands:

```
kubectl get clusters
kubectl get work
kubectl get workset
```

You can copy hcmctl from hybrid-cluster-manager-v2 image by running
```
docker run -it -v /usr/local/bin:/data registry.ng.bluemix.net/mdelder/hybrid-cluster-manager-v2-amd64 cp /hcm /data/hcmctl
```

Then you can run
```
hcmctl get pods
hcmctl get nodes
hcmctl get cluster
hcmctl get clusterstatus
```