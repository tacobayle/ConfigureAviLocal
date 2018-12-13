# ConfigureAviLocal
Prerequisites:
- Make sure Ansible is installed
- Make sure a Vm (to host the Avi Controller) is reachable
- Make sure N Vm(s) (to host the Avi SEs) is/are reachable

Use the bash script to:
- Create hosts file for Ansible
- copy ssh keys to all the VMs
- Update, Upgrade apt and install docker to all the VMs
- Transfer and Install the Avi Software in the VM controller
- Configure the IPs of the interfaces of the SEs

Example:
./ConfigureAviLocal.sh 192.168.17.151 avi avi123 se.txt

The script accepts the following customized parameters:
- AviControllerIp=$1
- AviUsername=$2
- AviPassword=$3
- AviSeListFile=$4

The following parameters can be configured within the ./ConfigureAviLocal.sh file:
AuthorizedKeyFile="/home/avi/ssh/authorized_keys"
AviControllerCpu="6"
AviControllerMem="16"
AviBinFile="/home/avi/bin/avi/docker_install-18.1.3-9144.tar.gz"

A file ($4) needs to be define with the IPs of the SE and the interfaces acording to the syntax below:

more se.txt
192.168.17.152
se1,iface,eth1,2.1.1.11/8
se1,iface,eth2,172.16.1.101/24
192.168.17.153
se2,iface,eth1,2.1.1.12/8
se2,iface,eth2,172.16.1.102/24

Script has been tested against:
- VM runs Ubuntu 14.04.05
- Avi 18.1.3
- Ansible 2.7.0
