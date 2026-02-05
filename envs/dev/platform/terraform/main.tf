terraform {
  required_version = ">= 1.14.0"
}

provider "aws" {
  region = "ap-south-1"
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket         = "akash-platform-tf-state-1"
    key            = "envs/dev/network/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
  }
}

output "network_vpc_id" {
  value = data.terraform_remote_state.network.outputs.vpc_id
}

output "network_public_subnets" {
  value = data.terraform_remote_state.network.outputs.public_subnet_ids
}

output "network_private_subnet" {
  value = data.terraform_remote_state.network.outputs.private_subnet_ids
}
