#!/bin/bash

# Save old KUBECONFIG
OLD_KUBECONFIG=$KUBECONFIG

USER=$1
if [ -z $USER ]; then
  echo 'No username given'
  exit 1
fi

CLUSTER_NAME=$2
if [ -z $CLUSTER_NAME ]; then
  echo 'No clustername given'
  exit 2
fi

if [ ! -f /usr/bin/kubectl ]; then
  echo 'kubectl not found'
  exit 3
fi

NAMESPACE=internal

# Create internal Namespace
kubectl create namespace ${NAMESPACE} > /dev/null

# Create user ServiceAccount
kubectl create serviceaccount ${USER} -n ${NAMESPACE} > /dev/null

# Get Secret name
SECRET=$(kubectl get serviceaccount -n ${NAMESPACE} ${USER} -o yaml | grep -oE "${USER}\-token\-.+$")

# Get token value
TOKEN=$(kubectl get secret -n ${NAMESPACE} ${SECRET} -o yaml | grep -oE "token: .+$" | awk '{print $2}' | base64 -d)

# Give this ServiceAccount admin privileges
kubectl create clusterrolebinding serviceaccount:user:${USER} --clusterrole=cluster-admin --serviceaccount=${NAMESPACE}:${USER} > /dev/null

KUBE_MASTER=$(kubectl config view --output jsonpath='{.clusters[0].cluster.server}')

TMP_KUBECONFIG=$(mktemp)
export KUBECONFIG=$TMP_KUBECONFIG

kubectl config set-cluster ${CLUSTER_NAME} --server=${KUBE_MASTER} --certificate-authority=/etc/kubernetes/pki/ca.crt --embed-certs=true > /dev/null
kubectl config set-credentials ${USER} --token=${TOKEN} > /dev/null
kubectl config set-context ${CLUSTER_NAME} --cluster=${CLUSTER_NAME} --user=${USER} > /dev/null
kubectl config use-context ${CLUSTER_NAME} > /dev/null

export KUBECONFIG=$OLD_KUBECONFIG

cat ${TMP_KUBECONFIG}
rm ${TMP_KUBECONFIG}
