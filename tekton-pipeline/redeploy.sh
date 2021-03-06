#!/bin/bash
tput reset


oc delete sts -n demo mqtest-ibm-mq

ibmcloud cr image-rm de.icr.io/vcailly/builtmq:9.1.3
sleep 5

cd ..
git add * -A
git commit -m "12th commit"
git push
cd tekton-pipeline
oc apply -f resources/git.yaml
oc apply -f pipeline/pipeline.yaml
oc apply -f task/build-src-code.yaml 
oc apply -f task/deploy-to-cluster.yaml 
oc delete pr mq-pipeline-run
oc apply -f pipeline/pipeline-run.yaml

