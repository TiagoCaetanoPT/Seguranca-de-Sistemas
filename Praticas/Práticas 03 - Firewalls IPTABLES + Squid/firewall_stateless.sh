#!/bin/bash

echo "definir política por omissão: negar tudo"
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

echo "elimina todas as regras"
iptables -F

echo "Escrever as regras a seguir a esta linha"

  echo "permitir TUDO no localhost"
  iptables -A INPUT -i lo -j ACCEPT
  iptables -A OUTPUT -o lo -j ACCEPT

  echo "ping"
  iptables -A OUTPUT -p icmp -j ACCEPT
  iptables -A INPUT -p icmp -j ACCEPT

  echo "DNS"
  DNS=192.168.1.0/24
  iptables -A OUTPUT -p udp -d $DNS --sport 1024:65535 --dport 53 -j ACCEPT
  iptables -A INPUT -p udp -s $DNS --dport 1024:65535 --sport 53 -j ACCEPT


  echo "HTTP"
  iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
  iptables -A INPUT -p tcp --sport 80 -j ACCEPT


  echo "ssh - cliente"
  iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT
  iptables -A INPUT -p tcp --sport 22 -j ACCEPT

  echo "ssh - servidor"
  iptables -A INPUT -p tcp --dport 22 -j ACCEPT
  iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT
