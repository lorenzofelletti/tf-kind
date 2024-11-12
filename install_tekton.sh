#!/bin/bash
set -e -o pipefail

declare TEKTON_PIPELINE_VERSION TEKTON_TRIGGERS_VERSION TEKTON_DASHBOARD_VERSION

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

# Read command line options
while getopts ":c:p:t:d:k" opt; do
  case ${opt} in
    c )
      CLUSTER_NAME=$OPTARG
      ;;
    p )
      TEKTON_PIPELINE_VERSION=$OPTARG
      ;;
    t )
      TEKTON_TRIGGERS_VERSION=$OPTARG
      ;;
    d )
      TEKTON_DASHBOARD_VERSION=$OPTARG
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      echo 1>&2
      echo "Usage:  install_tekton.sh [-c cluster-name -p pipeline-version -t triggers-version -d dashboard-version"
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac
done
shift $((OPTIND -1))

if [ -z "$TEKTON_PIPELINE_VERSION" ]; then
  TEKTON_PIPELINE_VERSION=$(get_latest_release tektoncd/pipeline)
fi
if [ -z "$TEKTON_TRIGGERS_VERSION" ]; then
  TEKTON_TRIGGERS_VERSION=$(get_latest_release tektoncd/triggers)
fi
if [ -z "$TEKTON_DASHBOARD_VERSION" ]; then
  TEKTON_DASHBOARD_VERSION=$(get_latest_release tektoncd/dashboard)
fi

# Install Tekton Pipeline, Triggers and Dashboard
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/previous/${TEKTON_PIPELINE_VERSION}/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/previous/${TEKTON_TRIGGERS_VERSION}/release.yaml
kubectl wait --for=condition=Established --timeout=30s crds/clusterinterceptors.triggers.tekton.dev || true # Starting from triggers v0.13
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/previous/${TEKTON_TRIGGERS_VERSION}/interceptors.yaml || true
kubectl apply -f https://storage.googleapis.com/tekton-releases/dashboard/previous/${TEKTON_DASHBOARD_VERSION}/release-full.yaml

# Wait until all pods are ready
sleep 10
kubectl wait -n tekton-pipelines --for=condition=ready pods --all --timeout=120s
# kubectl port-forward service/tekton-dashboard -n tekton-pipelines 9097:9097 &> kind-tekton-dashboard.log &
# echo “Tekton Dashboard available at http://localhost:9097”
echo “Tekton installed successfully”
