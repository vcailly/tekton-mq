#!/bin/sh

cd /mnt/mqm-data/qmgrs/QM1/ssl
#0- create keystore
runmqckm -keydb -create -db QM1.kdb -type cms -stash  -pw Michelin
runmqckm -keydb -create -db CL1.kdb -type cms -stash  -pw Michelin

#1- create certificate,
runmqckm -cert -create -db QM1.kdb -pw Michelin -label ibmwebspheremqqm1   -dn "CN=QM1, O=IBM, C=FR" -size 1024 -x509version 3 -expire 365 -sig_alg SHA1WithRSA
runmqckm -cert -create -db CL1.kdb -pw Michelin -label ibmwebspheremqvcailly -dn "CN=APP, O=IBM, C=FR" -size 1024 -x509version 3 -expire 365 -sig_alg SHA1WithRSA

#2-Export Certificates
runmqckm -cert -export -db QM1.kdb -pw Michelin -label ibmwebspheremqqm1   -type cms -target QM1.pkcs -target_pw Michelin -target_type pkcs12
runmqckm -cert -export -db CL1.kdb -pw Michelin -label ibmwebspheremqvcailly -type cms -target CL1.pkcs -target_pw Michelin -target_type pkcs12

#3-Import Certificates
runmqckm -cert -import -file QM1.pkcs -pw Michelin -type pkcs12 -target  CL1.kdb -target_pw Michelin -target_type cms -label ibmwebspheremqqm1
runmqckm -cert -import -file CL1.pkcs -pw Michelin -type pkcs12 -target  QM1.kdb -target_pw Michelin -target_type cms -label ibmwebspheremqvcailly

cp CL1.* /tmp/

echo "ALTER QMGR SSLKEYR('/mnt/mqm-data/qmgrs/QM1/ssl/QM1')" | runmqsc QM1
echo "ALTER CHANNEL(DEV.APP.SVRCONN) CHLTYPE(SVRCONN) TRPTYPE(TCP) SSLCIPH(TLS_RSA_WITH_AES_128_CBC_SHA256) SSLCAUTH(REQUIRED)" | runmqsc QM1
echo "DEFINE CHANNEL(DEV.APP.SVRCONN) CHLTYPE(CLNTCONN) TRPTYPE(TCP) SSLCIPH(TLS_RSA_WITH_AES_128_CBC_SHA256) CERTLABL('ibmwebspheremqvcailly') CONNAME('mqtest-ibm-mq.demo.svc.cluster.local(1414)') QMNAME(QM1) USERID('admin') PASSWORD('admin')" | runmqsc QM1
echo "REFRESH SECURITY TYPE(SSL)" | runmqsc QM1

