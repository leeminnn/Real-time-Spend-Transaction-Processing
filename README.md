## How to setup our application

1) Get Terraform env file (not uploaded as it contains secrets) from the team
2) Place the env file in the `/app/devops` where we are running Terraform
3) Run the following commands:

	`$ cd /app/devops`
	`$ terraform init`
	`$ terraform apply -var-file="production.tfvars"`
