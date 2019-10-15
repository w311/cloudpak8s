---
title: Importing a kubernetes cluster into MCM
weight: 300
---
- 
{:toc}

## Onboarding a Kubernetes Cluster

MCM > Clusters > Add cluster > Import existing cluster > run commands from a terminal on your existing cluster (Manual)

Enter the same name for the `Cluster name` and the `Namespace`. This restriction is a temporary limitation in the MCM UI.

![Graphic]({{ site.github.url }}/assets/img/cp4mcm/import_cluster.png)

Click "Generate Command" button to get the configuration command.

![Graphic]({{ site.github.url }}/assets/img/cp4mcm/mcm_klusterlet_import_command.png)

Go to the managed cluster cli, and run the command copied from the above. You should see something simialr as below:

```
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  6412    0  6412    0     0   2872      0 --:--:--  0:00:02 --:--:--  2872
customresourcedefinition.apiextensions.k8s.io/endpoints.multicloud.ibm.com configured
namespace/multicluster-endpoint configured
secret/klusterlet-bootstrap configured
secret/multicluster-endpoint-operator-pull-secret configured
serviceaccount/ibm-multicluster-endpoint-operator configured
clusterrolebinding.rbac.authorization.k8s.io/ibm-multicluster-endpoint-operator configured
deployment.apps/ibm-multicluster-endpoint-operator configured
endpoint.multicloud.ibm.com/endpoint created

```
