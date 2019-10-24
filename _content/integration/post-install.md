---
title: Post-installation tasks
weight: 900
---

This page contains:

- [Loading ppas and images on Red Hat OpenShift on IBM Cloud](#loading-ppas-and-images-on-roks)
- [Loading ppas and images on-premise](#loading-ppas-and-images-on-premise)

## Loading ppas and images on Red Hat OpenShift on IBM Cloud

After installing the Integration Cloud Pak, you might wish to load further ppas or images. These instructions describe how to load images on a Red Hat OpenShift on IBM Cloud, managed service, environment.

1. Download the ppas you want to load to your computer or boot node.
2. We need to expose the docker registry of the OpenShift cluster to your node. To do so:
  - Login to Openshift with the `oc login` command found on the OpenShift UI.
  - Update the local /etc/hosts and add the line `127.0.0.1 docker-registry.default.svc`. You can edit this file by running this command from anywhere on the command line:
  ``` md
  sudo vi /etc/hosts
  ```
  - Expose port 5000 on the boot node. You need to leave the window open or else the port-forwarding will stop. To achieve this run this command:
  ``` md
  kubectl -n default port-forward svc/docker-registry 5000:5000
  ```
3. Sign into the docker registry. To login to the docker registry run:
  ``` md
  docker login -u $(oc whoami) -p $(oc whoami -t) docker-registry.default.svc:5000
  ```
4. Navigate on your command line to the folder with the ppa you want to load.
5. Load the ppa with:
  ``` md
  cloudctl catalog load-archive --archive <file-name> --registry docker-registry.default.svc:5000/<target-namespace>
  ```
6. Repeat the above for all the other packages listed above
7. Log in to ICP console and sync the repositories.
8. Go to Catalog and search for ppa you loaded.
9. You can now install and configure the ppa.

## Loading ppas and images on-premise

These instructions describe how to load images on an on-prem deploymend of the Integration Cloud Pak.

1. Download the ppas you want to load to your computer or boot node.
2. Login to Openshift with the `oc login` command found on the OpenShift UI.
3. Run `oc -n default get routes` to get the registry address for this cluster. Take note of it.
4. Sign into the docker registry. To login to the docker registry run:
  ``` md
  docker login -u $(oc whoami) -p $(oc whoami -t) <docker-registry-address>
  ```
5. Navigate on your command line to the folder with the ppa you want to load.
6. Load the ppa with:
  ``` md
  cloudctl catalog load-archive --archive <file-name> --registry <docker-registry-address>/<target-namespace>
  ```
7. Repeat the above for all the other packages listed above
8. Log in to ICP console and sync the repositories.
9. Go to Catalog and search for ppa you loaded.
10. You can now install and configure the ppa.