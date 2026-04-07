.PHONY: plan apply

plan: security-check
	terraform plan

apply: security-check
	terraform apply

security-check:
	terraform fmt --recursive
	tflint
	tfsec .
	checkov -d .