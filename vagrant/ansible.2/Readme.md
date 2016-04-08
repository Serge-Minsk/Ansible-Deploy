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

## Install Ansible on Mac OS X 

    brew update
    brew install ansible

## Install on CentOS/Redhat

    yum install ansible --enable=epel

## Ansible Basics

Start from learning [YAML](http://docs.ansible.com/ansible/YAMLSyntax.html) syntax

### Ansible Playbook Example

    ---
    - name: install and start apache
      hosts: webservers
      user: root

      tasks:

      - name: install httpd
        yum: name=httpd state=present

      - name: start httpd
        service: name=httpd state=running

* `---` in the top indicates that this is a `yaml` file
* `name` defines the name of the `play`
* `hosts` tells `ansible` which hosts this `playbook` targets
* `user` defines what system `ansible` user will use to execute the task below
* `tasks` list of task and task configurations `ansible` playbook will do

### Ansible `CLI` commands

    ansible -m <module-name> -u <user-name> <targeted-hosts>

    ansible-playbook <playbpook-name.yml> -e “user-var=user-var-value”

### Gather facts module

This module gets automatically called by playbooks to gather usefull information about
remote hosts that can be used in `playbooks`. It can also be executed directly by 
`/usr/bin/ansible` to check what variables are available to a host. 

__Examples:__

    # Display facts from all hosts and store them indexed by I(hostname) at C(/tmp/facts).
    ansible all -m setup --tree /tmp/facts

    # Display only facts regarding memory found by ansible on all hosts and output them.
    ansible all -m setup -a ‘filter=ansible_*_mb’

    # Display only facts returned by facter.
    ansible all -m setup -a ‘filter=facter_*’

    # Display only facts about certain interfaces.
    ansible all -m setup -a ‘filter=ansible_eth[0-2]’

## [Host Inventory](http://docs.ansible.com/ansible/intro_inventory.html)

Host inventory is a list of hosts organized into groups. It can come from a flat file, directory or 
cloud provisioning environment. 

__Examples:__

Simple example

    [web]
    webserver-1.example.com
    webserver-2.example.com

    [db]
    dbserver-1.example.com


Hosts range of web servers

    [web]
    webserverserver-[01:25].example.com

    [db]
    dbserver-[a:f].example.com

Non-standard `SSH` ports

    webserver.example.com:2222

SSH tunnel:

    myhost ansible_ssh_port=5555 ansible_ssh_host=192.168.0.1

Child groups:

    [east]
    host1
    host2

    [west]
    host3
    host4

    [us:children]
    east
    west

## Inventory plugins

* Cloud: Rackspace, DigitalOcean
* Bare-Metal (Cobber)
* Custom

## [Playbook Concepts](http://docs.ansible.com/ansible/playbooks_intro.html)

* Playbooks
* Plays
* Tasks and Handlers
* Modules
* Variables

### Playbooks

Playbooks contain plays.
Plays contain tasks.
Tasks contain modules.

Everything is sequentially ordered-strict dependency ordering. 
Handlers can be triggered by tasks, and will run at the end, once. 

__Advanced Playbook Features__

* `failed_when`, `changed_when`
* until keyword
* `ignore_errors`

### Tasks

A task calles module and may have parameters. Ansible has a lot of 
modules included, and you can write your own.

    tasks:
    - name: ensure apache is at the latest version
      yum: nae=httpd state=latest

    - name: write the apache config file
      templates: src=templates/httpd.j2 dest=/etc/httpd.conf

    - name: ensure apache is running
      service: name=httpd state=started

### [Modules](http://docs.ansible.com/ansible/modules.html)

`Ansible` is "batteries included". [List of Ansible modules](http://docs.ansible.com/list_of_all_modules.html)

* Package managment: __yum__, __apt__
* Remote execution: __command__, __shell__
* Service management: __service__
* File handling: __copy__, __template__
* SCM: __git__

#### [Command](http://docs.ansible.com/ansible/command_module.html) and [Shell](http://docs.ansible.com/ansible/shell_module.html#shell)

Execute arbitrary commands on remote hosts. 
You’ll want to use shell over commands, when you need environment access,
environment variables or pipe something.

    - name: turn off selinux
      command: /sbin/setenforce 0 

    - name: ignore return code
      shell: /usr/bin/somecommand && /bin/true

#### Long lines can wrap

    - name: Copy Ansible file to client
      copy: src=/etc/ansible/hosts
        dest=/etc/ansible/hosts
        owner=root group=root mode=0644


#### [Copy](http://docs.ansible.com/ansible/copy_module.html) and [Template](http://docs.ansible.com/ansible/template_module.html)
***Copy a file form `Ansible` host to managed host:***

    - name: copy a file
      copy: src=files/ntp.conf dest=/etc/ntp/ntp.conf
        owner=root group=root mode=0644

***Evaluate a `Jinjia2` template:***

    - name: Copy Ansible file to client
      template: src=templates/motd
        dest=/etc/motd
        owner=root group=root mode=0644

#### Package management with `apt` and `yum`
***Package management:***

    - name: install httpd
      yum: name=httpd state=present

    - name: install httpd
      apt: name=httpd-2.0 state=present

***Install a set of packages in one transaction:***

    - name: install a set of packages
      yum: name={{ item }} state=present
      with_items:
        - httpd
        - php
        - git
        - mysql-client

### [Variables](http://docs.ansible.com/ansible/playbooks_variables.html)

Variables can be defined in many different ways. 
There are several sources for variables: 

* Playbooks (vars, vars_files, host_vars, group_vars)
* Inventory (group vars, host vars)
* Command line
* Discovered variables (facts)


    `ansible -m setup -u <user-name> <host-name>` - this command will output list of all discovered variables. 

With this feature we can reference ip address variables in the template without 
even knowing the ip address we are working on. 

Discovered variables can be found with the help of `setup` module

    ansible -m setup hostname

Variables in a playbook:

    tasks: 
    - name: report this machine’s IP
      command: echo “My IP is {{ ansible_default_ipv4.address }}”

Variables in a template: 

    This is a template file, evaluated and then sent to the target machine.
    This machine’s IP address is {{ ansible_default_ipv4.address }}

Variables file: 

    ---
    # Variables for the HAproxy configuration

    # HAProxy supports "http" and "tcp".
    mode: http

    # Port on which HAProxy should listen
    listenport: 8888

    # A name for the proxy daemon, this will be the 
    # suffix in the logs
    daemonname: myapplb

    # Balancing algorithm:
    balance: roundrobin

    # Ethernet interface for haproxy 
    iface: '{{ ansible_default_ipv4.interface  }}'

### [Conditionals](http://docs.ansible.com/ansible/playbooks_conditionals.html)

The When Statement
Sometimes you will want to skip a particular step on a particular host. This could be something as simple as not installing a certain package if the operating system is a particular version, or it could be something like performing some cleanup steps if a filesystem is getting full.

This is easy to do in Ansible, with the when clause, which contains a Jinja2 expression (see Variables). It’s actually pretty simple:

    tasks:
    - name: "shutdown Debian flavored systems"
      command: /sbin/shutdown -t now
      when: ansible_os_family == "Debian"

You can also use parentheses to group conditions:

    tasks:
    - name: "shutdown CentOS 6 and Debian 7 systems"
      command: /sbin/shutdown -t now
      when: (ansible_distribution == "CentOS" and ansible_distribution_major_version == "6") or
            (ansible_distribution == "Debian" and ansible_distribution_major_version == "7")


### [Loops](http://docs.ansible.com/ansible/playbooks_loops.html)
We can also iterate over a list:
* `with_items`
* `with_together`
* `with_subelements`
* `with_sequence`
* `with_random_choice`
* `with_first_found`
* `with_lines`
* `with_flattened`
* etc...

## Roles

* Project organizational tool
* Reusable components
* Defined filesystem structure
* Show: parameterized roles

```
    webserver/
    |--files/
    |  |--epel.repo.j2
    |  `--RPM-GPG-KEY-EPEL-6
    |--handlers/
    |  `--main.yml
    |--library/
    |  `--my_own_module.py
    |--meta/
    |  `--main.yml
    |--tasks/
    |  `--main.yml
    |--templates/
    |  `--httpd.conf.j2
    |--vars/
       `--main.yml
```
Roles can have:

* Role variables
* Role defaults
* Role dependencies 
* Role custom modules

## Rolling Updates/Orchestration

* serial keyword
* `pre_tasks` and `post_tasks`
* `delegate_to`

## Looks ups

Plugin-based mechanism to look up data. For example we need to set up an authorized 
key file for one of the boxes we are controlling, instead of passing the ssh password, 
we are going to do a look up, so we don’t have to put a key in a playbook. We will 
basically cat out the file into memory, use that as a key and drop that into place.

    - name: set up authorized keys for demo boxes
      authorized_key: 
        user=vagrant
        key="{{ lookup('file', 'id_rsa.pub') }}"
        manage_dir=yes state=present

## Playbook Control

* `--tags`/`--skip-tags`
* `--limit`
* `--start-at-task`
* `--step`
* `--check`/`--diff`/`--syntax-check`

## Cloud Provisioning

* Cloud modules
* `add_host` module
* Provisioning versus configuration
* Dynamic inventory (ec2.py)

## Project Structure

* __files__: This directory contains regular files that need to be transferred to the hosts you are configuring for this role. This may also include script files to run.
* __handlers__: All handlers that were in your playbook previously can now be added into this directory.
* __meta__: This directory can contain files that establish role dependencies. You can list roles that must be applied before the current role can work correctly.
* __templates__: You can place all files that use variables to substitute information during creation in this directory.
* __tasks__: This directory contains all of the tasks that would normally be in a playbook. These can reference files and templates contained in their respective directories without using a path.
* __vars__: Variables for the roles can be specified in this directory and used in your configuration files.

### [Directory Layout](http://docs.ansible.com/ansible/playbooks_best_practices.html#directory-layout)
```
production                # inventory file for production servers
staging                   # inventory file for staging environment

group_vars/
   group1                 # here we assign variables to particular groups
   group2                 # ""
host_vars/
   hostname1              # if systems need specific variables, put them here
   hostname2              # ""

library/                  # if any custom modules, put them here (optional)
filter_plugins/           # if any custom filter plugins, put them here (optional)

site.yml                  # master playbook
webservers.yml            # playbook for webserver tier
dbservers.yml             # playbook for dbserver tier

roles/
    common/               # this hierarchy represents a "role"
        tasks/            #
            main.yml      #  <-- tasks file can include smaller files if warranted
        handlers/         #
            main.yml      #  <-- handlers file
        templates/        #  <-- files for use with the template resource
            ntp.conf.j2   #  <------- templates end in .j2
        files/            #
            bar.txt       #  <-- files for use with the copy resource
            foo.sh        #  <-- script files for use with the script resource
        vars/             #
            main.yml      #  <-- variables associated with this role
        defaults/         #
            main.yml      #  <-- default lower priority variables for this role
        meta/             #
            main.yml      #  <-- role dependencies

    webtier/              # same kind of structure as "common" was above, done for the webtier role
    monitoring/           # ""
    fooapp/               # ""
```



## [Ansible Galaxy](https://galaxy.ansible.com)

Ansible Galaxy is a hub for finding, reusing, and sharing the best Ansible content. Create an account there, we will need it a little later.

Install package from `ansible-galaxy`

    sudo ansible-galaxy install owner.repo

This command will download and extract package in `/etc/ansible/roles`.

## [Ansible Role Manager (ARM)](https://github.com/mirskytech/ansible-role-manager/)

Ansible Role Manager (ARM) is a tool for installing and managing Ansible roles, playbooks & modules. Compitable with `ansible-galaxy`.`ARM` is looking for a `playbook` in a current directory in order to navigate. 

Installation

    sudo pip install ansible-role-manager

Let's download a new role from github.com/owner/repo. It will be as easy as: 

    sudo arm install install owner.repo

This command will create `.installed_roles` folder, download the role and symlink it to `roles` folder. 

If we need to create a custom role name

    sudo arm install owner.repo#alias=custom_role_name

This command will download a role named `custom_role_name`.

## Ansible Vault



## Cheat Sheet 

### $ ansible

* Call a shell command `-a "$command"`
* Call with sudo rights `--sudo`
* Test if machine responses `-m ping`
* Call an arbitrary module `-m $module -a "$argument"`
* Gather specific facts `-m setup -a "filter=*distri*"`

### $ ansible-playbook

* Call a book `$host some/playbook.yaml`
* Run in parallel `-f 10`
* List affected hosts `--list-hosts`

### $ ansible-galaxy
* Init a new role `init new_role`

### Inventory

* General inventory `/etc/ansible/hosts`
* Shell variable `$ANSIBLE_HOSTS`
* Normal entry `www.example.com`
* Multi-definition `db[0-9].example.com`
* Custom ip `ansible_ssh_host`
* Grouping `[group]`
* Specific user `ansible_ssh_user`
* Specific port `ansible_ssh_port`

```
[my_group1]
my_host1
my_host2

[my_group1:vars]
variable1=value1

[my_group2]
my_host3
my_host4

[my_group2:vars]
variable2=value2

[my_union:children]
my_group1
my_group2

[my_union:vars]
union_variable=union_value
```

### Complex playbook.yaml

**Loop over items:**

    - name: copy file
      copy: src={{item.src}} dest={{item.dst}}
      with_items:
      - { src: a, dest: b }
      - { src: k, dest: l }

***Nested Loops:***

    - name: give users access to multiple databases
      mysql_user:
        name={{ item[0].name }}
        priv={{ item[1] }}.*:ALL
        append_privs=yes
        password={{ item[0].password }}
      with_nested:
      - [ { name: 'alice', password: 'paswd123' }, { name: 'bob', password: 'paswd345'} ]
      - [ 'clientdb', 'employeedb', 'providerdb' ]

Conditionals:
    
    - name: Install Apache2
      apt: name=apache2 state=installed
      when: ansible_os_family == "Debian"
      
    - name: Install Httpd
      yum: name=httpd state=installed
      when: ansible_os_family == "Redhat"

Roles:

    - name: Playbook Example
      hosts: webserver
      roles:
      - common
      - dbservers
    
```    
roles/
      common/
        files/
        templates/
        tasks/
           main.yml
        handlers/
           main.yml
        vars/
           main.yml
        meta/
           main.yml
    webservers/
```
