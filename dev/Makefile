
.DEFAULT_GOAL := help

init: ;@ ## Initialize workspace
	terraform -chdir="eks" init
	terraform -chdir="saas" init
.PHONY: init

plan: ;@ ## Perform eks dry run
	terraform -chdir="eks" plan
	terraform -chdir="saas" plan
.PHONY: plan

apply: ;@ ## Build eks infrastructure
	@echo "Provisioning infrastructure..."
	terraform -chdir="eks" apply

	v1=$(shell terraform -chdir="eks" output -raw vpc_id); \
	v2=$(shell terraform -chdir="eks" output -raw vpc_cidr_block); \
	v3=$(shell terraform -chdir="eks" output -raw database_subnet_group); \
	terraform -chdir="saas" apply \
	-var="vpc_id=$$v1" \
	-var="vpc_cidr_block=$$v2" \
	-var="database_subnet_group=$$v3"

	@M2M_POOL_ID=$(shell terraform -chdir="saas" output -raw shared_user_pool_id); \
    	M2M_USER="M2M-admin-client-application"; \
    	M2M_PASSWORD=$(shell openssl rand -hex 16); \
    	cd ..; ./scripts/create-m2m-clients.sh "$$M2M_POOL_ID" "$$M2M_USER" "P$$M2M_PASSWORD!"
.PHONY: apply

scripts: ;@ ## Execute post infrastructure setup scripts
	@CLUSTER_NAME=$(shell terraform -chdir="eks" output -raw eks_cluster_name); \
	aws eks --region $$AWS_DEFAULT_REGION update-kubeconfig --name $$CLUSTER_NAME;

	@cd ..; ./scripts/security-groups-for-pods.sh dev
	@cd ..; ./scripts/generate-secrets.sh dev
	@cd ..; ./scripts/argocd-login.sh
	@cd ..; ./scripts/create-argocd-app.sh
.PHONY: scripts

delete: ;@ ## Delete argocd application
	@cd ..; ./scripts/argocd-login.sh
	argocd --port-forward app delete dev-apps --cascade
.PHONY: delete

destroy: ;@ ## Destroy infrastructure
	@echo "WARNING! Destroying development environment infrastructure..."
	@cd ..; ./scripts/confirm.sh

	terraform -chdir="eks" destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
	terraform -chdir="eks" destroy -target="module.eks_blueprints" -auto-approve
	terraform -chdir="eks" destroy -auto-approve
	terraform -chdir="saas" destroy -auto-approve
.PHONY: destroy

help:
	@echo
	@echo "- Setup Instructions -"
	@echo
	@echo 1. make init
	@echo 2. make plan
	@echo 3. make apply
	@echo 4. make scripts
	@echo
	@grep -hE '^[ a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
.PHONY: help