#!/bin/sh
kubectl apply -f 00-application-crd.yaml
kubectl apply -f 01-clusterregistry-crd.yaml
kubectl apply -f 01-deployable-crd.yaml
kubectl apply -f 02-docker-pull-secret.yaml
kubectl apply -f 03-rbac.yaml
kubectl apply -f 04-controller-deployment.yaml
