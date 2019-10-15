---
title: Terraform
weight: 210
---

- 
{:toc}

## Terraform Introduction and Motivation

Terraform is an open source infrastructure automation tool, which can be installed from `https://terraform.io`. Using it, infrastructure can be declaratively specified, deployed, updated and versioned. The declarative definition of infrastructure resources is sometimes called "infrastructure as code". These declarations enable the same infrastructure setup to be reproduced to different instances and even different underlying infrastructure. This capability allows easy and reproduceable infrastructure environment deployment. 

As there are many terraform providers for cloud infrastructure vendors, terraform skills can be transferred between cloud providers to build platforms on multiple clouds.

Terraform is a useful tool for building *immutable infrastructure*, which is a paradigm where infrastructure is never modified after it is deployed.  This is allows the state of the infrastructure to be completely defined by the declarative definitions, and destroyed and recreated when problems arise.

### Terraform resources

In Terraform, a resource is a component of your infrastructure. It could be a low level component such as a physical server, virtual machine, or container. It could also be a higher level component such as an email provider, DNS record, or database provider. 

### Terraform providers

Infrastructure resources are provisioned by providers. Providers are responsible in Terraform for managing the lifecycle of a resource: create, read, update, delete. A provider definition includes the necessary credentials to access the infrastructure. A provider translates the declarative resources specified in the terraform language to API calls for the specific provider. Providers generally are available for an IaaS (e.g. AWS, GCP, Microsoft Azure, OpenStack), PaaS (e.g. Heroku), or SaaS service (e.g. Terraform Enterprise, DNSimple, CloudFlare).

Terraform uses provider plugins to generate resources for different infrastructure components. Plugins allow terraform capabilities to be extended and new resource classes to be provisioned. The providers and plugins maintained by Hashicorp, the creator of Terraform, reside in a set of repositories in the `terraform-providers` organization in Github. Third party providers and plugins can also be housed in other Github repositories.

### Terraform project layout

Terraform modules and resource definitions are defined in a set of `*.tf` files. A module is a grouping of multiple resources that are used together and deployed together. The most common set of `*.tf` files you will see in the current directory from which you run your terraform deployment are as follows:
 - `variables.tf` - This file contains the definitions for all the input variables needed to deploy the resources defined in the module. Typically this file contains variable declarations only, not variable values.
 - `outputs.tf` - This file defines any output or return value variables that will be produced. The output values can be used by another module performing the next step of a deployment.
 - `*.tf` - Any additional resources may be in other files with `*.tf` extension. The provider plugins that will be used to deploy those resources, the name and location of *modules*, each of which contains the definitions and instructions to deploy a resource, and necessary variables for those plugins, resources and modules. 
 - `terraform.tfvars` - This file is configured with the values to apply to variables declared in `variables.tf`. This file may contain credentials and should not be committed to source control without some type of access controls.

### Terraform execution

Before execution, prepare the variables file with all required variables as defined in `variables.tf`. Use the `terraform init` command to download all required terraform providers and modules to the local directory.

Using the `terraform plan` command, we can check what terraform will do without actually making any infrastructure changes, which is helpful to examine what would happen without incurring costs associated with creating or destroying resources.

When run using the `terraform apply` command, the variable substitutions are read from the `.tfvars` file.  Terraform internally generates a dependency graph and will begin provisioning resources in a topological order.

### Terraform state and drift detection

Terraform creates a state file with the `*.tfstate` extension to store the results of resources it has provisioned during every `terraform apply` run.  It uses this file to detect drift, which are differences in the actual infrastructure and terraform's own view of the resources it has created.  For example, if someone has removed a virtual machine after deployment, terraform is able to compare its state file with the live state and recreate the virtual machine according to the resource definitions.

### Terraform modules

Terraform modules may be packaged in sub-directories, or optionally, in git repositories for code reuse.  The main logic can be contained in a repo that can combine one or more modules to build a full end-to-end solution. That main repo may contains pointers to multiple modules, each of which can reside in its own github repo. These modules are typically self-contained functions that may need to be run in a certain sequence. Some of the components may be shared across different implementations. 

{% include_relative terraform_modules.md %}