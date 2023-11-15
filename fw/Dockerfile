FROM ubuntu:22.04
# FICHERO DE APROVISIONAMIENTO DEL FIREWALL

# Intenté trabajar con iptables-persistent, pero las reglas de IPTABLES no podían configurarse durante el aprovisionamiento 
# del contenedor, por falta de privilegios. Después de mirarlo por internet, las soluciones a esto parecen demasiado complicadas.
RUN apt-get update && apt-get install -y openssh-server net-tools iputils-ping traceroute nano iproute2 iptables pkg-config nmap tcpdump libtool check libssl-dev libpcap0.8-dev libpcre3-dev liblzma-dev

# Dependencias SNORT
#RUN apt-get install -y g++ 
#g++ make cmake

WORKDIR /root
COPY ./scripts/install_snort.sh .
RUN chmod +x install_snort.sh
RUN ./install_snort.sh
COPY ./config/dos.rules /usr/local/etc/rules/custom/dos.rules
COPY ./config/all.rules /usr/local/etc/rules/all.rules

RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN mkdir /root/.ssh

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


EXPOSE 22
EXPOSE 943

WORKDIR /root/
COPY ./config/hosts .

COPY ./start.sh .
COPY ./scripts ./scripts

COPY ./config/issue /etc/issue

RUN chmod +x start.sh scripts -R 

CMD ["./start.sh"]
