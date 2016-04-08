# Ansible
## What is Ansible

* Application Deployment
* Multi-Tier Orchectration
* Configuration Managment

## Ansible features

* Agent-less architecture
* No custom PKI-SSH-based
* Configuration as data, not code
* Batteries-included
* Full configuration managment, orchestration, and deployment

## Provisioning

The final version of provisioning is under [ansible.2](/vagrant/ansible.2/) directory with 4 roles available: [java](/vagrant/ansible.2/roles/java/), [jenkins](/vagrant/ansible.2/roles/jenkins/) (can be installed separately), [tomcat](/vagrant/ansible.2/roles/tomcat/) (can be installed separately), [app](/vagrant/ansible.2/roles/app/). There are default variables defined in [group_vars](/vagrant/ansible.2/group_vars/). Dependencies:

* app invokes jenkins and tomcat (with predefined parameters in [provision.yml](/vagrant/ansible.2/provision.yml));
* jenkins invokes java;
* tomcat invokes java;
```
├── group_vars
│   └── all
├── provision.retry
├── provision.yml
├── Readme.md
└── roles
    ├── app
    │   ├── defaults
    │   │   └── main.yml
    │   ├── files
    │   ├── handlers
    │   │   └── main.yml
    │   ├── meta
    │   │   └── main.yml
    │   ├── README.md
    │   ├── tasks
    │   │   └── main.yml
    │   ├── templates
    │   │   ├── iptables
    │   │   └── virtual.conf
    │   ├── tests
    │   │   ├── inventory
    │   │   └── test.yml
    │   └── vars
    │       └── main.yml
    ├── java
    │   ├── defaults
    │   │   └── main.yml
    │   ├── files
    │   ├── handlers
    │   │   └── main.yml
    │   ├── meta
    │   │   └── main.yml
    │   ├── README.md
    │   ├── tasks
    │   │   └── main.yml
    │   ├── templates
    │   ├── tests
    │   │   ├── inventory
    │   │   └── test.yml
    │   └── vars
    │       └── main.yml
    ├── jenkins
    │   ├── defaults
    │   │   └── main.yml
    │   ├── files
    │   │   ├── hudson.tasks.Maven.xml
    │   │   ├── jenkins
    │   │   ├── jenkins.repo
    │   │   └── jobs
    │   │       ├── build
    │   │       │   └── config.xml
    │   │       └── deploy
    │   │           └── config.xml
    │   ├── handlers
    │   │   └── main.yml
    │   ├── meta
    │   │   └── main.yml
    │   ├── README.md
    │   ├── tasks
    │   │   └── main.yml
    │   ├── templates
    │   │   ├── config.xml
    │   │   └── jenkins
    │   ├── tests
    │   │   ├── inventory
    │   │   └── test.yml
    │   └── vars
    │       └── main.yml
    └── tomcat
        ├── defaults
        │   └── main.yml
        ├── files
        │   ├── tomcat
        │   └── tomcat-init.sh
        ├── handlers
        │   └── main.yml
        ├── meta
        │   └── main.yml
        ├── README.md
        ├── tasks
        │   └── main.yml
        ├── templates
        │   └── server.xml
        ├── tests
        │   ├── inventory
        │   └── test.yml
        └── vars
            └── main.yml
```
