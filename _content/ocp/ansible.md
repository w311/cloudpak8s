---
title: Ansible
weight: 225
---

[Ansible](https://www.ansible.com) is a configuration automation tool used to build declarative, immutable configuration across infrastructure. Using it, routine tasks involving server configuration files can be declaratively defined and automated.

One characteristic of Ansible is that all tasks should be [idempotent](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html), which means that performing an operation once has the exact same result as performing it repeatedly.  This allows administrators to effectively define configuration state declaratively and have their automation run repeatedly over their infrastrcuture to correct problems with configuration drift.

Ansible performs operations without installing agents on the target nodes, and connects using SSH. Typically, operations are performed over multiple nodes in parallel from a single control or bastion host.  The target hosts are defined in an inventory file, and hosts can be grouped together based on their role.

Ansible tasks can be grouped together into a [playbook](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html), which are a set of tasks that can be performed together across various hosts.  The playbook format is typically in yaml.

Ansible playbooks can be scheduled and run from [Red Hat Ansible Tower](https://www.ansible.com/products/tower) which is a commercial product that can be used to ensure that infrastructure configuration is up to date by scheduling playbooks and detecting errors and configuration drift.

Openshift 3.x installation is delivered as an Ansible playbook. 