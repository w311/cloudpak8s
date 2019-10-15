#!/bin/sh
./login.sh
cloudctl catalog delete-helm-chart --name mqseries-mcm
cd ....../charts/stable/mqseries-mcm
helm package .
cloudctl catalog load-helm-chart --archive mqseries-mcm-0.1.0.tgz
cd -
