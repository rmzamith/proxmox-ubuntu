#Makefile!

# Terraform plan output file to save
PLAN_FILE ?=

.PHONY: help
help:
	@echo "Available targets:"
	@echo "    help: show this message"
	@echo "    template: build packer template"
	@echo "    plan: run terraform plan exporting secrets"
	@echo "    apply: run terraform apply exporting secrets"
	@echo "    destroy: run terraform destroy exporting secrets"
	@echo ""

.PHONY: template
template:
	# Build Ubuntu Server Template and update to Proxmox 
	@set +H; set -a; . ./.env; cd packer/; packer build -var-file=vars.json proxmox-ubuntu-server.pkr.hcl; set +a
	# Done!

.PHONY: plan
ifeq ("$(PLAN_FILE)","")
plan:
	# Export credentials and run terraform plan
	@set +H; set -a; . ./.env; cd tf/; terraform plan; set +a
	# Done!
else
plan:
	# Export credentials, run terraform plan and save to .tfplan file
	@cd tf/
	@set +H; set -a; . ./.env; cd tf/; terraform plan -out=$(PLAN_FILE); set +a
	# Done!
endif

.PHONY: apply
ifeq ("$(PLAN_FILE)","")
apply:
	# Export credentials and run terraform apply
	@set +H; set -a; . ./.env; cd tf/;  terraform apply; set +a
	# Done!
else
apply:
	# Export credentials and run terraform apply from plan file
	@set +H; set -a; . ./.env; cd tf/ terraform apply $(PLAN_FILE); set +a
	# Done!
endif

.PHONY: destroy
destroy:
	# Export credentials and run terraform destroy
	@set +H; set -a; . ./.env; cd tf/; terraform destroy; set +a
	# Done!
