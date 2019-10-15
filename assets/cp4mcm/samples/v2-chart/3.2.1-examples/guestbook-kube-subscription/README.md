# GuestBook Example with kube resource using Subscription

This example is trying to convert k8s guest book example [https://kubernetes.io/docs/tutorials/stateless-application/guestbook] into mcm application

Following 2 chart is for mcm-application

1. gbchn
2. gbapp

## What's New

1. Use Kube resource directly in deployable

## Usage

0. Clone the repo, package app charts with `helm package gbapp` `helm package gbchn`
1. Create a namespace for your channel `kubectl create namespace <your_channel_namespace_name>`
2. Install channel chart with GUI or CLI `helm install gbchn -n <your_channel-name> --namespace <your_channel_namespace_name> --tls `
3. Install application chart with GUI or CLI in your project namespace `helm install gbapp -n <release-name> --namespace <project_namespace> --set channel.name=<your_channel-name>,channel.namespace=<your_channel_namespace_name> --tls `
4. Update placement related values to redeploy application
5. Delete application helm release to deregister application `helm delete <release-name> --purge --tls`
6. Delete channel helm release to clean up channel `helm delete <channel-name> --purge --tls`

**Don't intall gbapp to your channel namespace directly, use another one.**

By default gbapp values enables the placement for multicluster, use following CLI to install it with placement disabled: `helm install gbapp -n <your_release_name> --set channel.name=<your_channel_name>,channel.namespace=<your_channel_namespace>,placement.multicluster.enabled=false --tls`

Note that if the multicluster placement is disabled, the application becomes single cluster application. Consequently all pods/services in the application are created in hub cluster directly.  As a result, the application dashboard link won't be shown as no managed clusters are involved.
