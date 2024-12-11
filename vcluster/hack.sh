export VCLUSTER_YAML="$(awk '{printf "%s\\n", $0}' vcluster.yaml)"

namespace=$1-vcluster

kubectl create namespace $namespace

clusterctl generate cluster $1 \
    --infrastructure vcluster:v0.2.0 \
    --target-namespace $namespace \
    | kubectl apply -f -
