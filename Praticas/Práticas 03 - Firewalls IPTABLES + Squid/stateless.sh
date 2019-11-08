#!/bin/bash

#chmod +x firewall.sh
#sudo ./firewall.sh

IPT=/sbin/iptables

echo "Definir a politica por omissao: negar"
$IPT -P INPUT DROP 
$IPT -P OUTPUT DROP
$IPT -P FORWARD DROP

echo "apagar regras antigas"
$IPT -F


#################################################
#              stateless rules                  #
#################################################

echo "permitir acesso ao localhost"
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT


#   cliente                             servidor
#x=[1024,65535] --------------------------> 80
#         <-------------------------------


DYN=1024:65535


echo "permitir acesso ao DNS"
$IPT -A OUTPUT -j ACCEPT -p udp --sport $DYN --dport 53
$IPT -A INPUT -j ACCEPT -p udp --sport 53 --dport $DYN

echo "permitir acesso ao DNS"
$IPT -A OUTPUT -j ACCEPT -p udp --sport $DYN --dport 53
$IPT -A INPUT -j ACCEPT -p udp --sport 53 --dport $DYN

echo "Nao permitir acesso ao Moodle"
$IPT -A OUTPUT -p tcp -d 172.20.24.10 --sport $DYN --dport https -j DROP

echo "permitir acesso ao HTTP"
$IPT -A OUTPUT -p tcp --sport $DYN --dport http -j ACCEPT
$IPT -A INPUT -p tcp --sport http --dport $DYN -j ACCEPT

echo "permitir acesso ao HTTPs"
$IPT -A OUTPUT -p tcp --sport $DYN --dport https -j ACCEPT
$IPT -A INPUT -p tcp --sport https --dport $DYN -j ACCEPT

echo "permitir acesso ao SSH -- cliente"
$IPT -A OUTPUT -p tcp --sport $DYN --dport 22 -j ACCEPT
$IPT -A INPUT -p tcp --sport 22 --dport $DYN -j ACCEPT

echo "permitir acesso ao SSH -- servidor"
$IPT -A INPUT -p tcp --sport $DYN --dport 22 -j ACCEPT
$IPT -A OUTPUT -p tcp --sport 22 --dport $DYN -j ACCEPT


