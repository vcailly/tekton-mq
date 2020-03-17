#!/bin/bash
tput reset
current()
{
  kubectl get sts ${sts} -n ${nspace} -o custom-columns=CURRENT:.status.currentReplicas --no-headers=true
}

ready()
{
  kubectl get sts ${sts} -n ${nspace} -o custom-columns=READY:.status.readyReplicas --no-headers=true
}

sts="mqtest-ibm-mq"
nspace="demo"
CURRENT=$(date +%s)

echo "get Active Pod"
echo "--------------"

active=${sts}-1
kubectl exec  ${sts}-0 -n ${nspace} -- dspmq | grep 'Running as standby'
[ $? -eq 1 ] && active=${sts}-0;
echo ${active}

echo "get Active Pod: done"

echo ""
echo "Create bkup dir if not exists"
echo "-----------------------------"

kubectl exec ${active} -n ${nspace} -- bash -c '[ ! -d "/mnt/mqm-data/qmgrs/bkup/" ] && mkdir "/mnt/mqm-data/qmgrs/bkup" || :'
echo "Create bkup dir if not exists: done"

echo ""
echo "Backup config "
echo "--------------"
#kubectl exec ${active} -n ${nspace} -- bash -c '[ -f /mnt/mqm-bkup/${MQ_QMGR_NAME}.mqsc ] && rm "/mnt/mqm-bkup/${MQ_QMGR_NAME}.mqsc"'
[ -f /mnt/mqm-bkup/${MQ_QMGR_NAME}.mqsc ] && rm "/mnt/mqm-bkup/${MQ_QMGR_NAME}.mqsc"
kubectl exec ${active} -n ${nspace} -- bash -c 'dmpmqcfg -m ${MQ_QMGR_NAME} -a >/mnt/mqm-data/qmgrs/${MQ_QMGR_NAME}.mqsc'
#kubectl exec ${active} -n ${nspace} -- bash -c 'cp /mnt/mqm-data/qmgrs/${MQ_QMGR_NAME}.mqsc /mnt/mqm-bkup/${MQ_QMGR_NAME}.mqsc'
cp /mnt/mqm-data/qmgrs/${MQ_QMGR_NAME}.mqsc /mnt/mqm-bkup/${MQ_QMGR_NAME}.mqsc

echo "Backup config: done"

echo ""
echo "scale down to 0 replicas "
echo "-------------------------"
kubectl patch sts  ${sts} -n ${nspace} --type='json' -p='[{"op": "replace", "path": "/spec/replicas", "value":0}]'
echo ''
until [ "`current`" == "<none>" ]; do
   printf '%s.'
  sleep 5
done
echo ''

echo "scale down to 0 replicas: done"

echo ""
echo "Backup Logs"
echo "-----------"

[ -f  /mnt/mqm-bkup/${MQ_QMGR_NAME}-log.tar.gz ] && rm /mnt/mqm-bkup/${MQ_QMGR_NAME}-log.tar.gz
tar -cvpzf  /mnt/mqm-bkup/${MQ_QMGR_NAME}-log.tar.gz   /mnt/mqm-log/log
echo ''
echo "done - duration ${SECONDS} seconds"

echo ""
echo "Backup Data"
echo "-----------"

[ -f  /mnt/mqm-bkup/${MQ_QMGR_NAME}-data.tar.gz ] && rm  /mnt/mqm-bkup/${MQ_QMGR_NAME}-data.tar.gz 
tar -cvpzf  /mnt/mqm-bkup/${MQ_QMGR_NAME}-data.tar.gz  /mnt/mqm-data/qmgrs/${MQ_QMGR_NAME}
echo ''
echo "Backup Data: done"

echo ""
echo "Patch statefullset with new MQ image version "
echo "---------------------------------------------"
kubectl patch sts  ${sts} -n ${nspace} --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/image", "value":"de.icr.io/vcailly/bsmmq:9.1.4.0-r1"}]'

echo ''
echo "Patch statefullset with new MQ image version : done"
 

echo ""
echo "scale up to 2 replicas "
echo "-------------------------"
kubectl patch sts  ${sts} -n ${nspace} --type='json' -p='[{"op": "replace", "path": "/spec/replicas", "value":2}]'
until [ "`current`" == "2" ]; do
#  kubectl get sts ${sts} -n ${nspace} -o custom-columns=CURRENT:.status.currentReplicas,READY:.status.readyReplicas
   printf '%s.'
  sleep 5
done
echo ''
echo "scale up to 2 replicas : done"
   

TARGET=$(date +%s)
SECONDS=$(( ($TARGET - $CURRENT) ))
echo ''
echo "Total duration = ${SECONDS} seconds"

exit




