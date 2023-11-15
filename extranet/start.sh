#!/bin/bash
route del default gw 10.5.0.254
route add default gw 10.5.0.1

cat hosts >> /etc/hosts

# Activamos el banner
sed -i "s@#Banner none@Banner /etc/issue@g" /etc/ssh/sshd_config

echo "Machine up with ip $(ip add | grep eth0 | tail -n 1 | head --bytes 21 | tail --bytes 12 && echo)"
/usr/sbin/sshd -D
