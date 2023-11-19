#!/bin/bash
route del default gw 10.5.1.254
route add default gw 10.5.1.1

cat hosts >> /etc/hosts

# Creamos un usuario sin privilegios
useradd -m leon
echo 'leon:leon' | chpasswd
# Bloqueamos el acceso con contraseñas vacías
sed -i "s@#PermitEmptyPasswords no@PermitEmptyPasswords no@g" /etc/ssh/sshd_config
# Permitimos el acceso con clave pública
sed -i "s@#PubkeyAuthentication yes@PubkeyAuthentication yes@g" /etc/ssh/sshd_config
# Establecemos el número máximo de intentos en 2
sed -i "s@#MaxAuthTries 6@MaxAuthTries 2@g" /etc/ssh/sshd_config
# Activamos el MOTD (banner después de un login con éxito)
sed -i "s@PrintMotd no@PrintMotd yes@g" /etc/ssh/sshd_config
# Activamos el banner
sed -i "s@#Banner none@Banner /etc/issue@g" /etc/ssh/sshd_config

# Regla para redirigir el tráfico del puerto 22 al 2222 (cowrie) que viene de la EXT
iptables -t nat -A PREROUTING -p tcp --dport 22 -s 10.5.0.0/24 -j REDIRECT --to-port 2222

echo "Starting Cowrie"
su cowrie -c "cd ~ && ls -l && ./start_cowrie.sh" > /dev/null 2>&1

echo "Machine up with ip $(ip add | grep eth0 | tail -n 1 | head --bytes 21 | tail --bytes 12)"
/usr/sbin/sshd -D
