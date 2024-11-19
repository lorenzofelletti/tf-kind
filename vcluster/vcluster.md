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
