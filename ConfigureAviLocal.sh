#!/bin/bash
#
# ./ConfigureAviLocal.sh 192.168.17.151 avi avi123 se.txt
#
AviControllerIp=$1
AviUsername=$2
AviPassword=$3
AviSeListFile=$4
#AviSeUsername=$5
#AviSePassword=$6
AuthorizedKeyFile="/home/avi/ssh/authorized_keys"
AviControllerCpu="6"
AviControllerMem="16"
AviBinFile="/home/avi/bin/avi/docker_install-18.1.3-9144.tar.gz"
#
#
#
mkdir vars 2>/dev/null
AuthorizedKeyFileBaseName=`basename /home/avi/ssh/authorized_keys`
AviBinFileBaseName=`basename $AviBinFile`
echo "---
all:
  children:
    ubuntu:
      children:
        se:
          hosts:" > hosts
i=1
for ip in `cat $AviSeListFile | grep -v iface`
  do
  echo "  - $ip" >> vars/se.yml
  echo "            se$i:
              ansible_host: $ip" >> hosts
  i=$((i+1))
  done
echo "        controller:
          hosts:
            controller1:
              ansible_host: $AviControllerIp
  vars:
    ansible_user: $AviUsername
    ansible_ssh_pass: $AviPassword
    ansible_become_pass: $AviPassword" >> hosts
ansible-playbook -i hosts --extra-vars="AuthorizedKeyFile=$AuthorizedKeyFile AuthorizedKeyFileBaseName=$AuthorizedKeyFileBaseName" TransferSshKey.yml
ansible-playbook -i hosts AptUpdateUpgradeDocker.yml
ansible-playbook -i hosts --extra-vars="AviControllerCpu=$AviControllerCpu AviControllerMem=$AviControllerMem AviControllerIp=$AviControllerIp AviBinFile=$AviBinFile AviBinFileBaseName=$AviBinFileBaseName" InstallAviSoftware.yml
#ansible-playbook -i hosts --extra-vars="bin_filename=docker_install-18.1.3-9144.tar.gz ip_controller=193.168.17.151" 03-install-controller.yml
i=1
for ip in `cat $AviSeListFile | grep -v iface`
  do
  sed -e "s/ServiceEngine/se$i/" < ConfigureSeIfcae.yml.ori > ConfigureSeIfcae.yml
  for iface in `cat $AviSeListFile | grep se$i,iface`
    do
    SeIface=`echo $iface | awk -F ',' '{print $3}'`
    SeIfaceIp=`echo $iface | awk -F ',' '{print $4}'`
    ansible-playbook -i hosts --extra-vars="SeIface=$SeIface SeIfaceIp=$SeIfaceIp" ConfigureSeIfcae.yml
    done
  i=$((i+1))
  done
rm -f hosts
#
#ansible-playbook -i hosts --extra-vars="iface=eth1 ip=2.1.1.11/8" 05-ipconfig-se1.yml
#ansible-playbook -i hosts --extra-vars="iface=eth2 ip=172.16.1.101/24" 05-ipconfig-se1.yml
#ansible-playbook -i hosts --extra-vars="iface=eth1 ip=2.1.1.12/8" 05-ipconfig-se2.yml
#ansible-playbook -i hosts --extra-vars="iface=eth2 ip=172.16.1.102/24" 05-ipconfig-se2.yml
