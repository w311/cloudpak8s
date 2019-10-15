# HelmRelease & Secret Channels
These three files create the base to deploy the MQ Advanced Server Developer chart using subscriptions.
1. `kubectl apply -f ./29-mqadvacnced-secret-vault-channel.yaml` creates a namespace channel and adds the `mq-secret` used to set the Admin and App passwords for the MQ Advanced Server release
2.  `kubectl apply -f ./30-mqadvanced-helm-channel.yaml` Creates an `ibmcom` namespace and `ibm-stable-chart` channel. This channel will be populated with a deployable for each publicly available chart. These templates can be used to build HelmRelease Custom Resources or to build Subscriptions for HelmReleases.
3. `kubectl apply -f ./31-mqadvanced-app-subscription.yaml` Creates an application and subscription to deploy the MQ Advanced Server Developer
chart.

## Notes
- The cluster selector is the same for both subscriptions so that the secret and chart are presented together in the MCM Application Console.
- If using only a namespace channel, the secret deployable and HelmRelease Custom Resource deployable
can reside in the same channel.
