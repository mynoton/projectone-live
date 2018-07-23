#================================================================
# Terraform Configuration
#================================================================

terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "projectone-state-dev"
    dynamodb_table = "projectone-state-lock-dev"
    region         = "ap-southeast-1"
    key            = "terraform.tfstate"
  }
}
