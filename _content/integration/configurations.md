---
title: Component configuration
weight: 600
---

This page contains guidance on how to configure the release of all the components of the Integration Cloud Pak. This includes:

1. Navigator
2. Asset Repo
3. App Connect Enterprise
4. MQ
5. EventStreams
6. API Connect
7. Aspera
8. Operations Dashboard
9. Deleting components

## App Connect Enterprise guidance

### values.yaml example

Configure the following values on your helm chart when you install App Connect Enterprise.

``` md
image:
  pullPolicy: Always
  pullSecret: `<deployer-dockercfg pull secret>` #Get this secret by running oc get secrets on the namespace you want to deploy in
license: accept
replicaCount: 1
security:
  initVolumeAsRoot: false
selectedCluster:
- ip: icp-proxy.`<cluster-hostname>` #For example, icp-proxy.cluster-openshift-0819-management.fyre.ibm.com
  label: local-cluster
  namespace: local-cluster
  value: local-cluster
tls:
  hostname: `<cluster-hostname>`
```

## API Connect

### Releasing APIC Cheatsheet

Here are some typical values you can use to release a small APIC instance. proxy_ip will be the IP of your master node if you co-located proxy and master.

- registry: docker-registry.default.svc:5000/apic/
- image pull secret: `<deployer-dockercfg-pull-secret>` #Get this secret by running `oc get secrets` on the namespace you want to deploy in
- storage class: `<block-storage-class-name>` #Get storage classes available by running `oc get sc`
- helm tls secret: apic-ent-helm-tls
- FQDNs:
  - mgmt FQDNs: management.`<proxy-ip>`.nip.io (x4)
  - portal FQDNs: portaldirector.`<proxy-ip>`.nip.io portalweb.`<proxy-ip>`.nip.io
  - analytics FQDNs: analyticsingestion.`<proxy-ip>`.nip.io analyticsclient.`<proxy-ip>`.nip.io
  - gateway FQDNs: apigateway.`<proxy-ip>`.nip.io gatewayendpoint.`<proxy-ip>`.nip.io
- mode: dev
- cassandra replicas: 1
- cassandra volume size: 20GB
- analytics volume size: 20GB

## Deleting a component

If things dont go as planned or you want to remove the component release completely, you can remove by:

1. Deleting the helm release with:
``` md
helm del --purge <release-name> --tls
```
2. Removing all components in a specific namespace with:
``` md
kubectl delete pod,sts,ds,sts,job,pvc -n <namespace-name> --all
```