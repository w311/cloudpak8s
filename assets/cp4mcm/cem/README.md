```
macbook:openldap rhine$ cloudctl iam ldaps
ID                                     Name       Server Type   Base DN         URL   
bd6f7800-d580-11e9-b54c-e95d0123c7ff   openLDAP   Custom        dc=ibm,dc=com   ldap://172.21.171.75:389   
macbook:openldap rhine$ cloudctl iam user-import -c bd6f7800-d580-11e9-b54c-e95d0123c7ff -u laura
Found 1 user(s). Do you want to import them? [y/N]> y
User laura imported

macbook:openldap rhine$ cloudctl iam user-import -c bd6f7800-d580-11e9-b54c-e95d0123c7ff -u tony
Found 1 user(s). Do you want to import them? [y/N]> y
User laura imported

macbook:openldap rhine$ cloudctl iam user-onboard id-mycluster-account -r PRIMARY_OWNER -u laura
OK
macbook:openldap rhine$ cloudctl iam user-onboard id-mycluster-account -r MEMBER -u tony
OK

macbook:openldap rhine$ cloudctl iam team-create europe 
OK

macbook:openldap rhine$ cloudctl iam teams
ID                                 Name                                       Groups   Users   
4b974267a20ab08b47fa7d0a597d258a   4b974267a20ab08b47fa7d0a597d258a-default   0        1   
europe                             europe                                     0        0   
icam-team                          icam_team

macbook:openldap rhine$ cloudctl iam resources |grep mcm
crn:v1:icp:private:k8:mycluster:n/mcm:::   
crn:v1:icp:private:helm-catalog:mycluster:r/local-charts::helm-charts:mqseries-mcm   
crn:v1:icp:private:helm-catalog:mycluster:r/mgmt-charts::helm-charts:ibm-mcm-kui   
crn:v1:icp:private:helm-catalog:mycluster:r/mgmt-charts::helm-charts:ibm-mcm-prod

macbook:openldap rhine$ cloudctl iam resource-add europe -r crn:v1:icp:private:k8:mycluster:n/mcm:::
Resource crn:v1:icp:private:k8:mycluster:n/mcm::: added
OK

```





