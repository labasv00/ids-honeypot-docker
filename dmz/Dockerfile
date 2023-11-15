FROM ubuntu:22.04

# FICHERO DE APROVISIONAMIENTO DEL CONTENEDOR PARA DMZ

#ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y openssh-server net-tools iputils-ping traceroute nano iproute2 iptables pkg-config nmap tcpdump
# Cowrie dependencies
RUN apt-get update && apt-get install -y python3.10-venv libssl-dev libffi-dev build-essential libpython3-dev python3-minimal authbind virtualenv
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd

RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin no/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN mkdir /root/.ssh

COPY ./config/motd /etc/motd
COPY ./config/issue /etc/issue

EXPOSE 22

# Añado mis propios scripts
WORKDIR /root/
COPY ./hosts .

COPY ./start.sh .
COPY ./scripts ./scripts

RUN chmod +x start.sh scripts -R

RUN ./scripts/install_cowrie.sh

CMD ["./start.sh"]
