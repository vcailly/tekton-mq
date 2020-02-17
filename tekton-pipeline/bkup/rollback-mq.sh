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
echo "Restore config "
echo "--------------"
cp  /mnt/mqm-bkup/${MQ_QMGR_NAME}.mqsc /mnt/mqm-data/qmgrs/${MQ_QMGR_NAME}.mqsc
kubectl exec ${active} -n ${nspace} -- bash -c 'runmqsc </mnt/mqm-data/qmgrs/${MQ_QMGR_NAME}.mqsc'

echo "Restore config: done"

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
echo "Restore data dir"
echo "----------------"

rm -rf /mnt/mqm-data/qmgrs/
tar xvzf /mnt/mqm-bkup/BSM-data.tar.gz -C /

echo "Restore data dir: done"
echo ""
echo "Restore log dir"
echo "----------------"
rm -rf /mnt/mqm-log/log/
tar xvzf /mnt/mqm-bkup/BSM-log.tar.gz -C /

echo "Restore log dir: done"
echo ""
echo "Patch statefullset with previous MQ image version "
echo "--------------------------------------------------"
kubectl patch sts  ${sts} -n ${nspace} --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/image", "value":"de.icr.io/vcailly/builtmq:9.1.3"}]'

echo ''
echo "Patch statefullset with previous MQ image version  : done"


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




