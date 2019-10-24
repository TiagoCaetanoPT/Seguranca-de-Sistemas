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
  
  #######################################
  #         Regras STATELESS            #
  #######################################
  
  echo "ping"
  iptables -A OUTPUT -p icmp --icmp-type echo-request -m limit --limit 6/minute --limit-burst 4 -j ACCEPT
  # iptables -A OUTPUT -p icmp --icmp-type echo-request -j DROP -> regra poer omissão
  iptables -A INTPUT -p icmp --icmp-type echo-reply -j ACCEPT
  
