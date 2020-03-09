FROM lachlanevenson/k8s-kubectl
#RUN useradd alice -G mqm && \
#    echo alice:passw0rd | chpasswd
COPY stsstatus.sh /
COPY upgrade-mq.sh /
COPY fast-upgrade.sh /
COPY rollback-mq.sh /
