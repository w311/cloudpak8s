---
title: Install Developer Tools (Windows)
weight: 450
---

## Prerequisites

Before beginning these steps you should have:
1. A github account (or Github Enterprise)
1. A Dockerhub account (needed to install docker)
1. A Red Hat entitled customer account (to install oc)
1. An IDE (Eclipse or VS Code to use with Codewind)
1. A login for your Openshift Container cluster


## Installing Client tools from web pages on the cluster

As part of installing the OC cluster and the Cloud Pak for Applications two web pages will be created. It is recommended that you use these pages to get the most current installation information about the client tools. This document will also provide links to these tools on the web.

When the OpenShift cluster is created, a reference page is generated for the OpenShift command line tools. There are several useful links on this page. Get this URL from your administrator.
{%
 include figure.html
 src="/assets/img/cp4a/cmdline_tools.png"
 alt="Command Line Tools"
%}

**Note:** You will need to authenticate (login) to your cluster.

When the Cloud Pak for Applications is installed, a "landing page" is created for the Kabanero Enterprise edition. Your administrator can give you this URL.
{%
 include figure.html
 src="/assets/img/cp4a/kabanero.png"
 alt="Command Line Tools"
%}

**Note:** You will need to authenticate (login) to your cluster.

## Command line tools

#### git

Install git for windows from: https://gitforwindows.org/

### OpenShift OpenShift command line interface (oc)

More information can be found here:
https://docs.openshift.com/container-platform/3.11/cli_reference/get_started_cli.html#installing-the-cli For complete installation instructions there is a video you should watch.
**Note:** You will need to login using your RedHat customer account.

oc is also available from https://github.com/openshift/origin/releases

**[Issue]** Cannot unzip directly to `Program Files` on Win 10 even with Admin rights.


### docker
Install docker from here:
https://docs.docker.com/install/
**Note:** You will need to authenticate (login) to docker.


#### Codewind: Eclipse or VS Code
The prerequisites are here: https://www.eclipse.org/codewind/installlocally.html

* Eclipse installation https://www.eclipse.org/codewind/mdteclipsegettingstarted.html
* VS Code installation: https://www.eclipse.org/codewind/mdteclipsegettingstarted.html

#### appsody

Follow the link on the icpa landing page.
Multiple platform installation instructions `https://appsody.dev/docs/getting-started/installation`
