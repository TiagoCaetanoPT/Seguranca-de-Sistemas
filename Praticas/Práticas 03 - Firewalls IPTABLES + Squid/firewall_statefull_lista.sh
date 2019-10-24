#!/bin/bash

##################################
# Inicialização
##################################

echo "definir política por omissão: negar tudo"
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

echo "elimina todas as regras"
iptables -F
iptables -X

##################################
# Regras stateless
##################################

echo "Escrever as regras a seguir a esta linha"

echo "permitir TUDO no localhost"
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

echo "ping"
iptables -A OUTPUT -p icmp -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT

##################################
# Regras statefull
##################################

##################################
# Listas personalizadas
##################################
echo "lista personalizada"
iptables -N RegistaLog
iptables -A RegistaLog -j LOG --log-prefix "RegistaLog "
iptables -A RegistaLog -j ACCEPT



echo "Regras genéricas"
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT


echo "DNS"
DNS=192.168.1.0/24
iptables -A OUTPUT -p udp  -m state --state NEW -d $DNS --sport 1024:65535 --dport 53 -j ACCEPT

echo "rejeitar entrada de DNS"
iptables -A INPUT -p udp  -m state --state NEW --dport 53 -j REJECT --reject-with icmp-port-unreachable
iptables -A INPUT -p tcp  -m state --state NEW --dport 53 -j REJECT --reject-with tcp-reset

echo "HTTP"
iptables -A OUTPUT -p tcp  -m state --state NEW  --dport 80 -j RegistaLog


echo "ssh - cliente"
iptables -A OUTPUT -p tcp  -m state --state NEW  --dport 22 -j RegistaLog
