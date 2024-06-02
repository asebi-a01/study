# Summary
1. Create two Almalinux Servers on Vagrant.
2. Setup node server to allow ssh connection
3. Setup controller server to use ansible
4. Try to use ansible playbook on controller server

# Prerequisite
- You need to have [Vagrant](https://www.vagrantup.com/) already installed on your computer.
- You choose the working directory is like C:\vagrant\ansible if you use Windows.

# Construct Almalinux Environments
Create Vagrantfile
```
Vagrant.configure("2") do |config|
  config.vm.define "controller" do |controller|
    controller.vm.box = "almalinux/9"
    controller.vm.hostname = "controller"
    controller.vm.network "private_network", ip: "192.168.0.10"

    controller.vm.provider "libvirt" do |vb|
      vb.cpus = "2"
      vb.memory = "2048"
    end
  end

  config.vm.define "node1" do |node1|
    node1.vm.box = "almalinux/9"
    node1.vm.hostname = "node1"
    node1.vm.network "private_network", ip: "192.168.0.20"

    node1.vm.provider "libvirt" do |vb|
      vb.cpus = "1"
      vb.memory = "1024"
    end
  end
end
```

It will create the following servers.
| No | Name | IPv4 | OS | vCPU | vRAM |
|---|---|---| --- | --- | --- |
|1|controller|192.168.0.10| Almalinux 9 | 1 | 1024 MB |
|2|node1|192.168.0.20| Almalinux 9 | 1 | 1024 MB |

## Start Vagrant insntances
```
vagrant up
```


# Setup node1

## set root password on node1

Log in to node1
```
vagrant ssh node1
```


Change root password
```
sudo passwd root
```

Verify that you can log in as root
```
su -
```
## change sshd_config on node1
backup sshd_config
```
cp -p /etc/ssh/sshd_config /etc/ssh/sshd_config.bk
```

```
sudo vi /etc/ssh/sshd_config
```
Add the following code
```
PasswordAuthentication yes
PermitRootLogin yes
```
restart sshd services
```
sudo systemctl restart sshd
```
## Change SELinux configration
backup selinux config
```
sudo cp -p /etc/selinux/config /etc/selinux/config.bk
```

edit selinux config
```
sudo vi /etc/selinux/config
```
change config
```
SELINUX=permissive
```
Log out from node1
```
exit # log out from root user
exit # log out from vagrant user
```
And restart the node1 instance with the following command
```
vagrant reload
```
And log in node 1 again
```
vagrant ssh node1
```
Check selinux status
```
sestatus
```
show status like below
```
[vagrant@node1 ~]$ sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   permissive
Mode from config file:          permissive
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      33
[vagrant@node1 ~]$
```

# Install ansible on controller
Log in to controller
```
vagrant ssh controller
```

Install pip package
```
sudo dnf install pip -y
```
Install ansible with pip
```
pip install ansible
```
Check installed ansible
```
ansible --version
```
show version like below
```
ansible [core 2.15.12]
  config file = None
  configured module search path = ['/home/vagrant/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/vagrant/.local/lib/python3.9/site-packages/ansible
  ansible collection location = /home/vagrant/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/vagrant/.local/bin/ansible
  python version = 3.9.18 (main, Sep  7 2023, 00:00:00) [GCC 11.4.1 20230605 (Red Hat 11.4.1-2)] (/usr/bin/python3)
  jinja version = 3.1.4
  libyaml = True

```

## prepare SSH key
Create ssh-key
```
ssh-keygen -t rsa -b 2048
```
Copy ssh-key to node1
```
ssh-copy-id root@192.168.0.20
```
it will show some questions like below. please enter key and set passphrase (but passprahse is not mandatory).
```
Enter file in which to save the key (/home/vagrant/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
```


Enter node1's root password. And then you will se the message
```
Now try logging into the machine, with:   "ssh 'root@192.168.0.20'"
and check to make sure that only the key(s) you wanted were added.
```

Enter "yes"
```
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

Enter node1's root Password
```
root@192.168.0.20's password:
```
You will see the messages
```
Now try logging into the machine, with:   "ssh 'root@192.168.0.20'"
and check to make sure that only the key(s) you wanted were added.
```

Verify that you can log in node1 from controller
```
ssh root@192.168.0.20
```
and execute `hostname`
```
[root@node1 ~]# hostname
node1
[root@node1 ~]#
```
log out from node1
```
exit
```



## Prepare to use ansible on controller

make an ansible directory on your home directory.
```
cd ~
mkdir ansible
cd ansible
```

Create inventory.ini

```
vi inventory.ini
```
write below, and exit vi with `:wq`
```
[servers]
node1 ansible_host=192.168.0.20 ansible_user=root
```
# Try to execute ansible command

## Execute ping command
```
ansible -i ~/ansible/inventory.ini servers -m ping
```
It will show messages like below:
```
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

## Create playbook

create test playbook.yml, it shows only hostname
```
vi ~/ansible/playbook.yml
```

```
---
- name: Show the hostname of node1
  hosts: servers
  tasks:
    - name: Execute the hostname command
      command: hostname
      register: hostname_output
      
    - name: Show hostname
      debug:
        msg: "{{ hostname_output.stdout }}"

```

Execute playbook.yml
```
ansible-playbook -i ~/ansible/inventory.ini playbook.yml
```
It will show messages like below
```
[vagrant@controller ansible]$ ansible -i ~/ansible/inventory.ini servers -m ping
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
[vagrant@controller ansible]$ vi ~/ansible/playbook.yml
[vagrant@controller ansible]$ ansible-playbook -i ~/ansible/inventory.ini playbook.yml

PLAY [Show the hostname of node1] ***************************************************************************

TASK [Gathering Facts] ********************************************************************************************
ok: [node1]

TASK [Execute the hostname command] *******************************************************************************
changed: [node1]

TASK [Show hostname] **********************************************************************************************
ok: [node1] => {
    "msg": "node1"
}

PLAY RECAP ********************************************************************************************************
node1                      : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0


[vagrant@controller ansible]$
```

EOF