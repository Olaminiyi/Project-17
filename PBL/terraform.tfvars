region = "us-west-2"

vpc_cidr = "172.16.0.0/16"

enable_dns_support = "true"

enable_dns_hostnames = "true"



preferred_number_of_public_subnets = 2

preferred_number_of_private_subnets = 4
environment                         = "dev"

tags = {
  Enviroment      = "production"
  Owner-Email     = "gloriaolamy@gmail.com"
  Managed-By      = "Terraform"
  Billing-Account = "486356681924"
}

#copy ami from an ubuntu server
ami = "ami-0eb199b995e2bc4e3"

keypair = "devops"

account_no = "486356681924"

master-password = "put your own password"

master-username = "put your own username"
