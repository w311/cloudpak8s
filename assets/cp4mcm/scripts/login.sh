cloudctl login -a https://icp-console.mcmresidency1-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud --skip-ssl-validation --u admin --p admin
oc login --token=XXXX-LLs --server=https://c100-e.us-east.containers.cloud.ibm.com:32653
docker login -u $(oc whoami) -p $(oc whoami -t) docker-registry.mcmresidency1-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud
