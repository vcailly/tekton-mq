#!/bin/bash
tput reset


oc delete sts -n demo mqtest-ibm-mq

oc delete pvc -n demo data-mqtest-ibm-mq-0 data-mqtest-ibm-mq-1 mqtest-ibm-mq-log mqtest-ibm-mq-qm
#oc delete svc -n demo mqtest-ibm-mq mqtest-ibm-mq-metrics
sleep 5
kubectl patch pvc mqtest-ibm-mq-log -n demo -p '{"metadata":{"finalizers": []}}' --type=merge
kubectl patch pvc mqtest-ibm-mq-qm -n demo -p '{"metadata":{"finalizers": []}}' --type=merge
kubectl patch pvc data-mqtest-ibm-mq-0 -n demo -p '{"metadata":{"finalizers": []}}' --type=merge
kubectl patch pvc data-mqtest-ibm-mq-1 -n demo -p '{"metadata":{"finalizers": []}}' --type=merge


