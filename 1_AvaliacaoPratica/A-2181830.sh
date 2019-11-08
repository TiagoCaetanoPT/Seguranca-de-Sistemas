#!/bin/bash 

##############################################################
#     Id
#       Full name: Tiago Oliveira Caetano
#       Student number: 2181830
##############################################################


###############################
# Init. of iptables
###############################
  IPT=/usr/bin/iptables

  echo "Default policy"
  $IPT -P INPUT DROP
  $IPT -P OUTPUT DROP
  $IPT -P FORWARD DROP


  echo "Flush rules and personalized lists"
  $IPT -F
  $IPT -X

  DYN=1024:65535

###############################
# STATELESS rules
###############################

# identify the item number in your answers
echo "item x - do this and that"
  
  
###############################
# STATEFUL rules
###############################  
  
# identify the item number in your answers
echo "item x - do this and that"  

echo "permitir acesso ao DNS por UDP"
$IPT -A OUTPUT -j ACCEPT -s 192.168.1.0/24 -p udp --sport $DYN --dport 53
$IPT -A INPUT -j ACCEPT -s 192.168.1.0/24 -p udp --sport 53 --dport $DYN

echo "permitir acesso destination-unreachable"
$IPT -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
$IPT -A OUTPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
$IPT -A FORWARD -p icmp --icmp-type destination-unreachable -j ACCEPT

echo "permitir acesso time-exceeded"
$IPT -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
$IPT -A OUTPUT -p icmp --icmp-type time-exceeded -j ACCEPT

echo "permitir acesso parameter-problem"
$IPT -A INPUT -p icmp --icmp-type parameter-problem -j ACCEPT
$IPT -A OUTPUT -p icmp --icmp-type parameter-problem -j ACCEPT

echo "permitir acesso echo-request"
$IPT -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
$IPT -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT

echo "permitir acesso echo-reply"
$IPT -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
$IPT -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT

echo "Prevenis sobrecarga SYN-FLOOD"
$IPT -N sobrecarga
$IPT -A sobrecarga -m limit --limit 10/second --limit-burst 10 -j LOG --log-prefix "SYN negado" 
$IPT -A sobrecarga -j DROP

echo "permitir acesso FTP como cliente"
$IPT -A OUTPUT -p tcp --sport $DYN --dport 21 -j ACCEPT

echo "permitir acesso SSH como servidor"
SSH_1=14.15.20.0/22
SSH_2=15.44.60.0/23
SSH_3=18.51.2.0/24
echo "Registar como invalido"
$IPT -N invalido
$IPT -A invalido -p tcp -s $SSH_1 --sport $DYN --dport 22 -j LOG --log-prefix "INVALIDO" 
$IPT -A invalido -p tcp -s $SSH_2 --sport $DYN --dport 22 -j LOG --log-prefix "INVALIDO" 
$IPT -A invalido -p tcp -s $SSH_3 --sport $DYN --dport 22 -j LOG --log-prefix "INVALIDO" 
$IPT -A invalido -j DROP
$IPT -A INPUT -p tcp --sport $DYN --dport 22 -j ACCEPT
$IPT -A OUTPUT -p tcp --sport 22 --dport $DYN -j ACCEPT

echo "permitir o Ruca à rede 192.168.0.0/16"
$IPT -A INPUT -m owner --uid-owner 1001 -d 192.168.0.0/16 -j ACCEPT

echo "END"
