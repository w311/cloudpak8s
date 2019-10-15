### Connecting an MCM Channel to the local Helm Repo

[Sample from dominique-vernier](https://github.ibm.com/IBMPrivateCloud/roadmap/issues/31789#issuecomment-14583243)

Create a Channel in the hub for helm-repo (type: HelmRepo)

#### Channel sample
```
apiVersion: app.ibm.com/v1alpha1
kind: Channel
metadata:
  name: dev
  namespace: default
spec:
  type: HelmRepo
  pathname: https://mycluster.icp:8443/helm-repo/charts
  configRef:
    name: myhelmrepo-config
  secretRef:
    name: myhelmrepo-secret
```

The config-map referenced by the configRef must be created in the managed-cluster in the same name of the channel. Same for the secretRef. These 2 refs can also specify their own namespace for these CRs.

#### configMap sample

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: mycluster-config
  namespace: default
data:
  insecureSkipVerify: "true"
```

The configMap support only 1 parameter for the time being: insecureSkipVerify. If true the hostname will be not verify.

#### Secret sample

```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: artifact-secret
  namespace: default
data:
  user: yyyy (base64)
  password: xxxxx (base64)
```

The secret contains user and password, if provided it will be used to authenticate against the helm-repo.

#### create the Subcription on the hub

```
apiVersion: app.ibm.com/v1alpha1
kind: Subscription
metadata:
  annotations:
    tillerVersion: 2.4.0
  name: dev-sub-deploy
  namespace: default
spec:
  channel: default/dev
  name: myhelmchart
  packageFilter:
    annotations:
      tillerVersion: 2.4.0
    version: ">0.2.2"
  packageOverrides:
  - packageName: myhelmchart
    packageOverrides:
    - path: spec.values
      value: |
          valueName1: value 1
          valueName2: value 2
```

The spec.name define the helm-chart to deploy. 

This field is mandatory.

As a helm-repo can contains multiple helm-chart with the same name but with different versions, the spec.packageFilter contains filters to select a subset of versions (tillerVersion,version or digest). if still multiple versions are eligible after the filtering, the higher version will be taken.

The spec.packageOverrides allows you to provide values for the helm-chart. The spec.packageOverrides.packageName must be the same as the spec.name

- The subscription will be propagated to the managed cluster. The subscription controler running on the end-point will start to process the subscription, read the channel to get the configRef and secretRef. Connect the helm-repo to download the index.yaml and create a helmrelease CR.

- The helmrelease CR will be processed by the helm-crd controller and the helm-chart will be deployed.


#### Debugging

log of the subscription controller
log of the helm-crd controller.
Both are running on kube-system.


