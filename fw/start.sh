#!/bin/bash

# SCRIPT DE ARRANQUE DEL FIREWALL

function interface_or_exit() {
  interface=$1

  if [ -z "$interface" ]; then
    echo "The interface could not be found"
    exit -1
  fi
}

# Activamos la redirección
echo 1 > /proc/sys/net/ipv4/ip_forward

# Localizamos las interfaces
intranet_interface=$(ip add | grep 10.5.2 -B 2 | head -n 1 | grep -Eo '[A-Za-z0-9]+@' | sed 's/@//')
extranet_interface=$(ip add | grep 10.5.0 -B 2 | head -n 1 | grep -Eo '[A-Za-z0-9]+@' | sed 's/@//')
dmz_interface=$(ip add | grep 10.5.1 -B 2 | head -n 1 | grep -Eo '[A-Za-z0-9]+@' | sed 's/@//')
interface_or_exit $intranet_interface
interface_or_exit $extranet_interface
interface_or_exit $dmz_interface	

printf "Configuration for FIREWALL.\n  |_ interface intranet: '$intranet_interface'\n  |_ interface dmz: '$dmz_interface'\n  |_ interface extranet: '$extranet_interface'\n"

# Activamos el banner
sed -i "s@#Banner none@Banner /etc/issue@g" /etc/ssh/sshd_config

echo "Machine up"
cd ~
cat hosts >> /etc/hosts

# Alias de SNORT
alias snort=/usr/local/bin/snort
SNORT_INSTALL_DIR=/usr/local/

# Configuramos SNORT
# Configuramos la red interna para la intranet y la dmz
sed -i "s@HOME_NET = 'any'@HOME_NET = '10.5.2.0/24,10.5.1.0/24'@g" $SNORT_INSTALL_DIR/etc/snort/snort.lua
# Configuramos la red externa a todo lo que no es la interna 
sed -i "s@EXTERNAL_NET = 'any'@EXTERNAL_NET = '\!\$HOME_NET'@g" $SNORT_INSTALL_DIR/etc/snort/snort.lua
# Configuramos la ruta para las reglas (para no tener que añadirla a cada comando de Snort)
sed -i "s@-- use include for rules files; be sure to set your path@include = RULE_PATH .. '/all.rules',@g" $SNORT_INSTALL_DIR/etc/snort/snort.lua

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp --dport 22 -i eth1 -d 10.5.1.20 -j ACCEPT
iptables -A FORWARD -p tcp --dport 22 -i eth2 -d 10.5.1.20 -j ACCEPT

# Comprobamos la sintaxis de la configuracón de SNORT (y también de las reglas, porque la ruta está especificada dentro del lua de snort)
snort -c /usr/local/etc/snort/snort.lua > /dev/null 2>&1
if [ $? -eq 0 ]; then

  # Arrancamos SNORT
  echo "Valid SNORT config. Starting snort..."
  echo "> Writing Snort output to /var/log/snort.log"
  snort -c /usr/local/etc/snort/snort.lua -i $extranet_interface -A full >> /var/log/snort.log 2>&1
  if [ $? -ne 0 ]; then
    echo "Snort failed to start. Please try again with: "
    echo "snort -c /usr/local/etc/snort/snort.lua -i $extranet_interface -A full"
  fi

else
  echo "Invalid SNORT config"
fi

/usr/sbin/sshd -D
