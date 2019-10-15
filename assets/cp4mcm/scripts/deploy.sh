#!/bin/sh
helm install . --name mq101 --namespace mq --tls
helm list mq101 --tls
oc get Pods -n mq --show-labels
oc get StatefulSet -n mq --show-labels
oc get Service -n mq --show-labels
