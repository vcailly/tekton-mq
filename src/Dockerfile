FROM ibmcom/mq:9.1.3.0-r3
#RUN useradd alice -G mqm && \
#    echo alice:passw0rd | chpasswd
#COPY custom-mqsc /etc/mqm/
COPY config.mqsc /etc/mqm/
COPY 15-tls.mqsc /etc/mqm/
COPY amqauthg.sh /tmp/
#COPY 20-config.mqsc /etc/mqm/

