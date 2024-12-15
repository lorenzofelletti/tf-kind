#!/bin/bash
set -e

version=v0.2.0

if [ -z "$1" ]; then
    echo "Usage: $0 <cluster-name> [local-domain]"
    exit 1
fi

export CLUSTER_NAME=$1
export CLUSTER_NAMESPACE="${1}-vcluster"
export LOCAL_DOMAIN=${2:-"local.io"}

TMP_FILE=$(mktemp)
envsubst < vcluster.yaml > $TMP_FILE
export VCLUSTER_YAML="$(awk '{printf "%s\\n", $0}' $TMP_FILE)"

cat $TMP_FILE

if [[ -z "$(kubectl get namespace $CLUSTER_NAMESPACE --ignore-not-found)" ]]; then
    kubectl create namespace $CLUSTER_NAMESPACE
fi

clusterctl generate cluster $CLUSTER_NAME \
    --infrastructure vcluster:${version} \
    --target-namespace $CLUSTER_NAMESPACE \
    | kubectl apply -f -
