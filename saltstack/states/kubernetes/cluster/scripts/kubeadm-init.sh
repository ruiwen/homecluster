#!/bin/bash

/usr/bin/kubeadm init \
  --apiserver-advertise-address={{ pillar['kubernetes']['cluster']['master_host'] }} \
  --apiserver-bind-port={{ pillar['kubernetes']['cluster']['master_port'] }} \
  --service-cidr={{ pillar['kubernetes']['cluster']['service_cidr'] }} \
  --pod-network-cidr={{ pillar['kubernetes']['cluster']['pod_cidr'] }} \
  --token={{ pillar['kubernetes']['cluster']['token'] }}  | tee /tmp/k8s/kubeadm.log | grep -oE "\-\-token.+$"  | awk '{ print $2 > "/tmp/k8s/join_token"; print $4 > "/tmp/k8s/ca_hash" }'
  # --token={{ pillar['kubernetes']['cluster']['token'] }}  | grep -oE "\-\-token.+$" | tee /tmp/k8s/kubeadm.log | awk '{ print $2 > "/tmp/k8s/join_token"; print $4 > "/tmp/k8s/ca_hash" }'

#  --node-name={{ grains['localhost'] }} \
# --feature-gates={# pillar['kubernetes']['cluster']['features'] #} \
#| awk '{printf "- k8s_join_token %s\n- k8s_ca_hash: %s\n", $2, $4}' >> /tmp/kube-



