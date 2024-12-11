# Virtual Cluster (vCluster)

## Install Provider for Cluster API
> Prerequisite: `make kustomize-apply`

```bash
clusterctl init --infrastructure vcluster:v0.2.0
```

## Create a Virtual Cluster
```bash
./hack.sh <cluster-name>
```

## Fetch And Set Kubeconfig
```bash
k get secret -n vtest-vcluster vtest-ext-kubeconfig -o yaml | yq '.data.config' | base64 -d | yq . > kubeconfig
export KUBECONFIG=kubeconfig
```
