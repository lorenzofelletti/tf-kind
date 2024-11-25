#!/bin/bash
set -e

version=v0.2.0
export CLUSTER_NAME=$1
export CLUSTER_NAMESPACE="${1}-cluster"

TMP_FILE=$(mktemp)
envsubst < vcluster.yaml > $TMP_FILE
export VCLUSTER_YAML="$(awk '{printf "%s\\n", $0}' $TMP_FILE)"


if [[ -z "$(kubectl get namespace $CLUSTER_NAMESPACE --ignore-not-found)" ]]
    kubectl create namespace $CLUSTER_NAMESPACE
fi

clusterctl generate cluster $CLUSTER_NAME \
    --infrastructure vcluster:${version} \
    --target-namespace $CLUSTER_NAMESPACE \
    | kubectl apply -f -
