# Kubernetes Observability
Spin up a Kubernetes cluster with Prometheus and Grafana installed using Docker, and Terraform.
The repo provides IaC to create a Kubernetes cluster using Kind, but the Prometheus and Grafana setup can be used with any Kubernetes cluster.

## Setup MinIO
Run the following command to start MinIO:
```bash
make minio-up
```
> If you want to customise the MinIO setup, create a `.env` file in the `minio` directory using the `default.env` file as a template.
>
> The `default.env` file provides default values good enough for local development.

## Setup Terraform State Backend on MinIO
1. Connect to the MinIO web interface and create a bucket named `terraform-states` with
    - Locking enabled
    - Versioning enabled.

2. Create another bucket named `cluster-kubeconfig` to store the kubeconfig file for the Kind cluster (which will be useless at the moment,
because MinIO Terraform provider does not provide a way to read from bucket yet).

3. Create a user with the necessary permissions to read/write to the buckets (choose the IAM setup that suits your needs best). ([example here](#Example-IAM-Setup))

4. Create a pair of keys for the user, take note of them and download the `credentials.json` file. Then copy the credentials file
to the root of this repository.

5. `tpl-config.s3.tfbackend` file contains the template that will be used for the S3 backend configuration of each stack. The default configuration
is the one tested and working with the codebase. If you want your stacks to use a different configuration, you can edit it. The template configuration
is used by make to generate the actual configuration for each stack before `init` is run (see the `Makefile` for more details).

## Create Cluster
The cluster IaC is in the `terraform/kind-cluster` directory.
A `dev.tfvars` file is provided to set up a cluster using a pre-packaged configuration.

Run the following command to create the cluster:
```bash
# file path is relative to the terraform/kind-cluster directory
make init STACK=kind ARGS="-backend-config=config.s3.tfbackend"
make plan STACK=kind ARGS="-var-file=dev.tfvars"
make apply STACK=kind ARGS="-var-file=dev.tfvars"
```

### Setup Prometheus And Grafana
Once that the cluster is created, run the following command to set up Prometheus and Grafana:
```bash
make init STACK=observability ARGS="-backend-config=config.s3.tfbackend"
make plan STACK=observability ARGS="-var-file=dev.tfvars"
make apply STACK=observability ARGS="-var-file=dev.tfvars"
```

---
## Example IAM Setup
1. Go to the MinIO console (e.g. `http://localhost:9001` if you're using the default configuration).
2. Navigate to *Identity* > *Groups* and create a group named `terraform-admins` by
  - Clicking on the *Create Group* button
  - Setting the group name to `terraform-admins`
  - Clicking on the *Save* button
3. Set the policy for the group by
  - Clicking on the newly created group `terraform-admins`
  - Clicking on the *Policies* tab and then clicking on the *Set Policies* button
  - From the policies list, select `consoleAdmin`, `diagnostics` and `readwrite` policies, then click *Save*
4. Navigate to *Identity* > *Users* and create a new user by
  - Clicking on the *Create User* button
  - Setting the *User Name* to `terraform`, and setting the *Password* to whatever you want
  -  Assign the `terraform-admins` group in the *Assing Group* section
  - Clicking on the *Save* button
5. From the *Users* page create a new pair of credentials by
  - Clicking on the newly created user `terraform`
  - Clicking on the *Service Accounts* tab of the user
  - Clicking on the *Create Access Key* button
  - Clicking on the *Create* button
  - Taking note of the *Access Key* and *Secret Key* and downloading the `credentials.json` file
6. Eventually, further restrict the service account permissions by
  - Clicking on the Service Account Access Key that you want to restrict, and, for example, restrict the buckets that can be accessed by
    applying the following change
    ```json
    // in the statements section of the policy
    "Statement": [
      {
       "Effect": "Allow",
       "Action": [
        "s3:*"
       ],
       "Resource": [
        // change the default "arn:aws:s3:::*" to the following
        "arn:aws:s3:::cluster-kubeconfig*",
        "arn:aws:s3:::terraform-states/*"
       ]
      },
    ]
    ```
  - Then clicking on the *Update* button.
