# Quote of the Day application

qotdapp - application Helm chart
qotdchn - channel Helm chart

#### Loading helm charts into the Catalog

```
cloudctl catalog load-chart --archive qod-web-1.0.0.tgz
cloudctl catalog load-chart --archive qod-api-1.0.0.tgz 
cloudctl catalog load-chart --archive qodapp-0.1.0.tgz 
```
This loading of these charts is in anticipation of us subscribing to the MCM CHannel connected to our local Helm Repo.

See [Connecting an MCM Channel to the local ICP Helm Repo](https://github.ibm.com/IBMPrivateCloud/roadmap/issues/31789)

https://github.ibm.com/IBMPrivateCloud/roadmap/issues/31789#issuecomment-14583243

This example is `work in progress`

September 2019 - KRH

