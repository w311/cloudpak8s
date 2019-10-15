cloudctl login -a https://icp-console.mcmresidency1-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud --skip-ssl-validation --u admin --p admin
oc login --token=FHdS5OOC6KjJtMl9GxhzI6rG4qTmnntL_v3GpWl-LLs --server=https://c100-e.us-east.containers.cloud.ibm.com:32653
docker login -u $(oc whoami) -p $(oc whoami -t) docker-registry.mcmresidency1-6550a99fb8cff23207ccecc2183787a9-0001.us-east.containers.appdomain.cloud
