#FROM ibmcom/mq:9.1.3.0-r3
FROM de.icr.io/vcailly/basemmq:9.1.3.0-r3
#FROM de.icr.io/vcailly/basemmq:9.1.4.0-r1
#COPY custom-mqsc /etc/mqm/
COPY config.mqsc /etc/mqm/
COPY amqauthg.sh /tmp/
COPY mutualauth.sh /tmp/
