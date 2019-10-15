#!/bin/sh

if [[ ( $# -gt 1 || $# -eq 0 ) ]]; then
    printf "Usage:\n  $0 <deployment-namespace>\n"
    exit 1
fi

kubectl create -f - << EOF 
apiVersion: batch/v1
kind: Job
metadata:
  labels:
    chart: ibm-iisee-zen
    heritage: Tiller
  name: volumes-patch-cassandra
spec:
  template:
    metadata:
      labels:
        chart: ibm-iisee-zen
    spec:
      containers:
      - args:
        - chown 9042:9042 /mount-cassandra;
        command:
        - sh
        - -c
        - --
        image: alpine:latest 
        imagePullPolicy: IfNotPresent
        name: permissionsfix 
        resources: {}
        volumeMounts:
        - mountPath: /mount-cassandra
          name: cass-data 
      restartPolicy: Never
      securityContext: 
         runAsUser: 0
      terminationGracePeriodSeconds: 30
      volumes:
      - name: cass-data
        persistentVolumeClaim:
          claimName: cassandra-data-cassandra-0 
EOF

kubectl create -f - << EOF 
apiVersion: batch/v1
kind: Job
metadata:
  labels:
    chart: ibm-iisee-zen
    heritage: Tiller
  name: volumes-patch-kafka
spec:
  template:
    metadata:
      labels:
        chart: ibm-iisee-zen
    spec:
      containers:
      - args:
        - chown 9092:9092 /mount-kafka;
        command:
        - sh
        - -c
        - --
        image: alpine:latest 
        imagePullPolicy: IfNotPresent
        name: permissionsfix 
        resources: {}
        volumeMounts:
        - mountPath: /mount-kafka
          name: kafka-data
      restartPolicy: Never
      securityContext: 
         runAsUser: 0
      terminationGracePeriodSeconds: 30
      volumes:
      - name: kafka-data
        persistentVolumeClaim:
          claimName: kafka-data-kafka-0
EOF

kubectl create -f - << EOF 
apiVersion: batch/v1
kind: Job
metadata:
  labels:
    chart: ibm-iisee-zen
    heritage: Tiller
  name: volumes-patch-solr
spec:
  template:
    metadata:
      labels:
        chart: ibm-iisee-zen
    spec:
      containers:
      - args:
        - chown 8983:8983 /mount-solr;
        command:
        - sh
        - -c
        - --
        image: alpine:latest 
        imagePullPolicy: IfNotPresent
        name: permissionsfix 
        resources: {}
        volumeMounts:
        - mountPath: /mount-solr
          name: solr-data
      restartPolicy: Never
      securityContext: 
         runAsUser: 0
      terminationGracePeriodSeconds: 30
      volumes:
      - name: solr-data
        persistentVolumeClaim:
          claimName: solr-data-solr-0
EOF

sleep 60 

kubectl delete pod kafka-0 -n $1 
kubectl delete pod solr-0 -n $1 
kubectl delete pod cassandra-0 -n $1 
