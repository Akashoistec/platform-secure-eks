terraform {
  backend "s3" {
    bucket         = "akash-platform-tf-state-1"
    key            = "envs/dev/platform/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
