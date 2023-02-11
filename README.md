# Salt Master - Dockerfile

SaltStack is a bit like Group Policy Objects in Microsoft Windows Server, may be a little more then that.<br/>
[Project Home Page](https://saltproject.io/)<br/>
[Wikipedia Page](https://en.wikipedia.org/wiki/Salt_(software)) <br/>

Clone the Git Repository or Download the ZIP package and expand. CD into the folder. Then follow these steps to build docker container instance.

Build Docker Image:
```
docker build -t hammadrauf/saltmaster .
```
OR Pull from Docker Hub, Quay.io (Not uploaded yet).

Run Docker Conatiner:
```
docker run --name salt01 --restart always -d -p 4505:4505 -p 4506:4506 -p 8000:8000 -v salt_config:/etc/salt hammadrauf/saltmaster
```

Connect to BASH Shell in the Container:
```
docker exec -it salt01  /bin/bash
```

Then check status of Salt master like:

```
root@b10eb9518833:/home/salt# ps -ef | grep salt-master
root        38     1  1 15:10 ?        00:00:00 /usr/bin/python3 /usr/bin/salt-master -d
root        39    38  0 15:10 ?        00:00:00 /usr/bin/python3 /usr/bin/salt-master -d
root        42    38  0 15:10 ?        00:00:00 /usr/bin/python3 /usr/bin/salt-master -d
root        43    38  1 15:10 ?        00:00:00 /usr/bin/python3 /usr/bin/salt-master -d
root        44    38  0 15:10 ?        00:00:00 /usr/bin/python3 /usr/bin/salt-master -d
root        45    44  0 15:10 ?        00:00:00 /usr/bin/python3 /usr/bin/salt-master -d
root        50    44 11 15:10 ?        00:00:00 /usr/bin/python3 /usr/bin/salt-master -d
root        53    44 11 15:10 ?        00:00:00 /usr/bin/python3 /usr/bin/salt-master -d
root        54    44 10 15:10 ?        00:00:00 /usr/bin/python3 /usr/bin/salt-master -d
root        55    44 10 15:10 ?        00:00:00 /usr/bin/python3 /usr/bin/salt-master -d
root        58    44 10 15:10 ?        00:00:00 /usr/bin/python3 /usr/bin/salt-master -d
root        59    38  0 15:10 ?        00:00:00 /usr/bin/python3 /usr/bin/salt-master -d
root       721   714  0 15:10 pts/0    00:00:00 grep salt-master
root@b10eb9518833:/home/salt#
```

----

## Setting Secure communication between Salt-master and Minions

There is a general four step process to do this:

Generate the keys on the master:
```
root@saltmaster# salt-key --gen-keys=[key_name]
```

Pick a name for the key, such as the minion's id.

Add the public key to the accepted minion folder:

```
root@saltmaster# cp key_name.pub /etc/salt/pki/master/minions/[minion_id]
```

It is necessary that the public key file has the same name as your minion id. This is how Salt matches minions with their keys. Also note that the pki folder could be in a different location, depending on your OS or if specified in the master config file.

Distribute the minion keys.

There is no single method to get the keypair to your minion. The difficulty is finding a distribution method which is secure. For Amazon EC2 only, an AWS best practice is to use IAM Roles to pass credentials. (See: [blog post](https://aws.amazon.com/blogs/security/using-iam-roles-to-distribute-non-aws-credentials-to-your-ec2-instances/) )

Security Warning

Since the minion key is already accepted on the master, distributing the private key poses a potential security risk. A malicious party will have access to your entire state tree and other sensitive data if they gain access to a preseeded minion key.

Preseed the Minion with the keys

You will want to place the minion keys before starting the salt-minion daemon:

```
/etc/salt/pki/minion/minion.pem
/etc/salt/pki/minion/minion.pub
```

Once in place, you should be able to start salt-minion and run salt-call state.apply or any other salt commands that require master authentication.

----

KEY IDENTITY
Salt provides commands to validate the identity of your Salt master and Salt minions before the initial key exchange. Validating key identity helps avoid inadvertently connecting to the wrong Salt master, and helps prevent a potential MiTM attack when establishing the initial connection.

MASTER KEY FINGERPRINT
Print the master key fingerprint by running the following command on the Salt master:
```
salt-key -F master
```

Copy the master.pub fingerprint from the Local Keys section, and then set this value as the master_finger in the minion configuration file. Save the configuration file and then restart the Salt minion.

MINION KEY FINGERPRINT
Run the following command on each Salt minion to view the minion key fingerprint:

```
salt-call --local key.finger
```
Compare this value to the value that is displayed when you run the salt-key --finger <MINION_ID> command on the Salt master.

----

## SaltStack Reference Links

[https://agardner.net/saltstack-101-setup-configuration/](https://agardner.net/saltstack-101-setup-configuration/)

[SaltStack 101 Part 1](https://bencane.com/2013/09/03/getting-started-with-saltstack-by-example-automatically-installing-nginx/)

[SaltStack 101 Part 2 - Running Adhoc Commands](https://bencane.com/2013/09/23/remote-command-execution-with-saltstack/)


----

## Debug Port connections

Check open ports

Linux:
```
netstat -tulpn
```

Windows:
```
netstat -na
netstat -ao
netstat -na | find "4505"
netstat -ao | find "4505"
```

Show Process ID in Windows (Running under podman machine - wsl):
```
C:\Users\uname>netstat -noa | find "4506"
  TCP    127.0.0.1:4506         0.0.0.0:0              LISTENING       11816

C:\Users\uname>netstat -noa | find "8000"
  TCP    127.0.0.1:8000         0.0.0.0:0              LISTENING       11816

C:\Users\uname>netstat -noa | find "4505"
  TCP    127.0.0.1:4505         0.0.0.0:0              LISTENING       11816
```  

To Show Process Name in Windows:
```
C:\Users\uname>tasklist /fi "pid eq 11816"

Image Name                     PID Session Name        Session#    Mem Usage
========================= ======== ================ =========== ============
wslhost.exe                  11816 Console                    1      7,948 K
```

On Windows 10/11 Port 4505, 4506 may be occupied by "IP Helper" Service in Windows 11. Disable the service (Or reconfigure Salt Master to use different ports).

1. Click search and type in Services, open it.
2. Scroll down until you find an entry called "IP Helper", right click it, then click restart.
3. Scroll all the way down to the bottom and do the same thing for "Xbox Live Networking Service"

[About "IP Helper"](https://docs.microsoft.com/en-us/windows-hardware/drivers/network/ip-helper)

----

## Learn Salt Stack

Contents
- Comparison of popular configuration management tools
- Introduction to Infrastructure as Code (IaC) – Basics
- Minions and Keys
- States and High State
- Grains
- Pillars
- Execution Modules and State Modules
- Jinja
- Expressions
- Macros
- Filter
- Apply formulas
- Beacons (Monitor Files)


