ENV ?= dev

init:
	cd envs/$(ENV) && terraform init -backend-config=backend.hcl

plan:
	cd envs/$(ENV) && terraform plan

apply:
	cd envs/$(ENV) && terraform apply -auto-approve

outputs:
	cd envs/$(ENV) && terraform output -json | jq

fmt:
	terraform fmt -recursive
