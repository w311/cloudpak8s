---
title: Governance and Risk
weight: 500
---

-  
{:toc}

## Introduction

Here we can define and review policy definitions and see the compliance state of managed clusters.

### Policy example 1

Let's create a new policy

![Image]({{ site.github.url }}/assets/img/cp4mcm/PolicyCreate.png)

Identify what sort of Policy you want to create from the supplied templates. We will select `deny network request`. This could be used to quarantine a namespace.

![Image]({{ site.github.url }}/assets/img/cp4mcm/PolicySpecifications.png)

This policy stops all traffic to the `default` namespace on any cluster with the `environment: Dev` label. If you set this `enforce` then this will stop you being able to login to the ICP console, so ONLY use `inform`

![Image]({{ site.github.url }}/assets/img/cp4mcm/NetworkPolicyNoInbound.png)

### Policy example 2

And another policy where we need to have a namespace called `Prod` defined on all clusters where `namespace: Dev` is true.

![Image]({{ site.github.url }}/assets/img/cp4mcm/prodnamespace.png)

Here is the YAML that this generates.

![Image]({{ site.github.url }}/assets/img/cp4mcm/prodnamespaceyaml.png)

As we have set this policy to `enforce` this will create a `prod` namespace on our targeted clusters.

>oc get namespace \| grep -i prod

```
prod                                Active    5m
```

Create some more policies and then explore the console that is used to give a high level view of the cluster compliance with your defined Policies.

Start with a high level view of the cluster policy compliance.

![Image]({{ site.github.url }}/assets/img/cp4mcm/PolicySummary.png)

Then by `category` look at which clusters are found to be not compliant with named policies.

![Image]({{ site.github.url }}/assets/img/cp4mcm/ClusterSummary2.png)


![Image]({{ site.github.url }}/assets/img/cp4mcm/PolicyCollection.png)

Finally, look at all of the policy compliance associated with you collection of `PCI` compliance policies.

![Image]({{ site.github.url }}/assets/img/cp4mcm/SISummary.png)



