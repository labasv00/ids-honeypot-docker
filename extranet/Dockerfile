FROM ubuntu:22.04

# FICHERO DE APROVISIONAMIENTO DEL CONTENEDOR DE EXTRANET

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y openssh-server net-tools iputils-ping nano iproute2 iptables pkg-config nmap tcpdump hping3
#RUN apt-get install -y apache2

RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN mkdir /root/.ssh

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 22

WORKDIR /root/
COPY ./hosts .

COPY ./start.sh .
COPY ./scripts ./scripts

COPY ./issue /etc/issue

RUN chmod +x start.sh scripts -R

CMD ["./start.sh"]
