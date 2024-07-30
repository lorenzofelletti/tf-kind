SHELL := /bin/bash

PWD = $(shell pwd)
MINIO_DIR = minio
MINIO_ENV_FILE = .env
MINIO_DEFAULT_ENV_FILE = default.env
MINIO_CREDENTIALS_FILE = credentials.json

TERRAFORM_DIR = terraform
TERRAFORM_KIND_CLUSTER_DIR = $(TERRAFORM_DIR)/kind-cluster
TERRAFORM_OBSERVABILITY_DIR = $(TERRAFORM_DIR)/observability
TERRAFORM_VELERO_DIR = $(TERRAFORM_DIR)/velero

TF_MINIO_AUTO_TF_VARS_TPL = tpl-minio.auto.tfvars
TF_BACKEND_CFG_TPL = tpl-config.s3.tfbackend
TF_BACKEND_CFG_NAME = config.s3.tfbackend
TF_PLAN_FILE = terraform.tfplan

.PHONY: minio-up
minio-up:
	@cd $(MINIO_DIR); if [[ -f $(MINIO_ENV_FILE) ]]; then \
		echo "Using custom environment variables"; \
		source $(MINIO_ENV_FILE) && envsubst < docker-compose.yaml | docker-compose -f - up -d; \
	else \
		echo "Using default environment variables"; \
		source $(MINIO_DEFAULT_ENV_FILE) && envsubst < docker-compose.yaml | docker-compose -f - up -d; \
	fi

.PHONY: minio-down
minio-down:
	cd $(MINIO_DIR); docker-compose down


.PHONY: tf-backend-config
tf-backend-config:
	@export ACCESS_KEY=$$(cat $(MINIO_CREDENTIALS_FILE) | jq -r '.accessKey'); \
	export SECRET_KEY=$$(cat $(MINIO_CREDENTIALS_FILE) | jq -r '.secretKey'); \
	for dir in $$(find $(TERRAFORM_DIR) -maxdepth 1 -mindepth 1 -type d ! -name "modules"); do \
		export STACK=$$(echo -n "$$dir" | rev | cut -f1 -d/ | rev); \
		envsubst < $(TF_BACKEND_CFG_TPL) > "$$dir/$(TF_BACKEND_CFG_NAME)"; \
	done

.PHONY: auto-tf-vars
auto-tf-vars:
	@if [[ -f $(MINIO_DIR)/$(MINIO_ENV_FILE) ]]; then \
		source $(MINIO_DIR)/$(MINIO_ENV_FILE); \
	else \
		source $(MINIO_DIR)/$(MINIO_DEFAULT_ENV_FILE); \
	fi; envsubst < $(TF_MINIO_AUTO_TF_VARS_TPL) > $(TERRAFORM_DIR)/$(TERRAFORM_KIND_CLUSTER_DIR)/minio.auto.tfvars


.PHONY: init
init: tf-backend-config # auto-tf-vars
	@if [[ $(STACK) == "kind" ]]; then \
		$(call terraform-init, $(TERRAFORM_KIND_CLUSTER_DIR), $(ARGS)); \
	elif [[ $(STACK) == "observability" || $(STACK) == "obs" ]]; then \
		$(call terraform-init, $(TERRAFORM_OBSERVABILITY_DIR), $(ARGS)); \
	elif [[ $(STACK) == "velero" ]]; then \
		$(call terraform-init, $(TERRAFORM_VELERO_DIR), $(ARGS)); \
	else \
		echo "Invalid STACK value. Must be one of kind, observability (abbr. obs), and velero."; \
	fi

.PHONY: validate
validate:
	@if [[ $(STACK) == "kind" ]]; then \
		$(call terraform-validate, $(TERRAFORM_KIND_CLUSTER_DIR)); \
	elif [[ $(STACK) == "observability" || $(STACK) == "obs" ]]; then \
		$(call terraform-validate, $(TERRAFORM_OBSERVABILITY_DIR)); \
	elif [[ $(STACK) == "velero" ]]; then \
		$(call terraform-validate, $(TERRAFORM_VELERO_DIR)); \
	else \
		echo "Invalid STACK value. Must be one of kind, observability (abbr. obs), and velero."; \
	fi

.PHONY: fmt
fmt:
	@if [[ $(STACK) == "kind" ]]; then \
		$(call terraform-fmt, $(TERRAFORM_KIND_CLUSTER_DIR)); \
	elif [[ $(STACK) == "observability" || $(STACK) == "obs" ]]; then \
		$(call terraform-fmt, $(TERRAFORM_OBSERVABILITY_DIR)); \
	else \
		echo "Invalid STACK value. Must be one of kind, observability (abbr. obs), and velero."; \
	fi

.PHONY: fmt-all
fmt-all:
	$(call terraform-fmt, $(TERRAFORM_KIND_CLUSTER_DIR))
	$(call terraform-fmt, $(TERRAFORM_OBSERVABILITY_DIR))

.PHONY: console
console: # auto-tf-vars
	@if [[ $(STACK) == "kind" ]]; then \
		$(call terraform-console, $(TERRAFORM_KIND_CLUSTER_DIR), $(ARGS)); \
	elif [[ $(STACK) == "observability" || $(STACK) == "obs" ]]; then \
		$(call terraform-console, $(TERRAFORM_OBSERVABILITY_DIR), $(ARGS)); \
	elif [[ $(STACK) == "velero" ]]; then \
		$(call terraform-console, $(TERRAFORM_VELERO_DIR), $(ARGS)); \
	else \
		echo "Invalid STACK value. Must be one of kind, observability (abbr. obs), and velero."; \
	fi

.PHONY: tf-test
tf-test:
	@if [[ $(STACK) == "kind" ]]; then \
		$(call terraform-test, $(TERRAFORM_KIND_CLUSTER_DIR), $(ARGS)); \
	elif [[ $(STACK) == "observability" || $(STACK) == "obs" ]]; then \
		$(call terraform-test, $(TERRAFORM_OBSERVABILITY_DIR), $(ARGS)); \
	elif [[ $(STACK) == "velero" ]]; then \
		$(call terraform-test, $(TERRAFORM_VELERO_DIR), $(ARGS)); \
	else \
		echo "Invalid STACK value. Must be one of kind, observability (abbr. obs), and velero."; \
	fi

.PHONY: plan
plan: # auto-tf-vars
	@if [[ $(STACK) == "kind" ]]; then \
		$(call cp-minio-creds, $(TERRAFORM_KIND_CLUSTER_DIR)); \
		$(call terraform-plan, $(TERRAFORM_KIND_CLUSTER_DIR), $(ARGS)); \
	elif [[ $(STACK) == "observability" || $(STACK) == "obs" ]]; then \
		$(call cp-minio-creds, $(TERRAFORM_OBSERVABILITY_DIR)); \
		$(call terraform-plan, $(TERRAFORM_OBSERVABILITY_DIR), $(ARGS)); \
	elif [[ $(STACK) == "velero" ]]; then \
		$(call cp-minio-creds, $(TERRAFORM_VELERO_DIR)); \
		$(call terraform-plan, $(TERRAFORM_VELERO_DIR), $(ARGS)); \
	else \
		echo "Invalid STACK value. Must be one of kind, observability (abbr. obs), and velero."; \
	fi

.PHONY: apply
apply: # auto-tf-vars
	@if [[ $(STACK) == "kind" ]]; then \
		$(call terraform-apply, $(TERRAFORM_KIND_CLUSTER_DIR)); \
	elif [[ $(STACK) == "observability" || $(STACK) == "obs" ]]; then \
		$(call terraform-apply, $(TERRAFORM_OBSERVABILITY_DIR)); \
	elif [[ $(STACK) == "velero" ]]; then \
		$(call terraform-apply, $(TERRAFORM_VELERO_DIR)); \
	else \
		echo "Invalid STACK value. Must be one of kind, observability (abbr. obs), and velero."; \
	fi

.PHONY: destroy
destroy:
	@if [[ $(STACK) == "kind" ]]; then \
		$(call destroy, $(TERRAFORM_KIND_CLUSTER_DIR), $(ARGS)); \
	elif [[ $(STACK) == "observability" || $(STACK) == "obs" ]]; then \
		$(call destroy, $(TERRAFORM_OBSERVABILITY_DIR), $(ARGS)); \
	elif [[ $(STACK) == "velero" ]]; then \
		$(call destroy, $(TERRAFORM_VELERO_DIR), $(ARGS)); \
	else \
		echo "Invalid STACK value. Must be one of kind, observability (abbr. obs), and velero."; \
	fi


define cp-minio-creds
	cp $(MINIO_CREDENTIALS_FILE) $(MINIO_CREDENTIALS_FILE)
endef

define terraform-validate
	cd $(1); terraform validate
endef

define terraform-fmt
	cd $(1); terraform fmt -recursive
endef

define terraform-console
	cd $(1); terraform console $(2)
endef

define terraform-init
	cd $(1); terraform init $(2)
endef

define terraform-test
	cd $(1); terraform test $(2)
endef

define terraform-plan
	cd $(1); terraform plan -out=$(TF_PLAN_FILE) $(2)
endef

define terraform-apply
	cd $(1); terraform apply $(TF_PLAN_FILE)
endef

define destroy
	cd $(1); terraform destroy $(2)
endef
