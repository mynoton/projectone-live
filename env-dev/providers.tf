#================================================================
# AWS Provider
#================================================================

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
  version = "~> 1.28"

}

#================================================================
# Azure Provider
#================================================================

provider "azurerm" {
  subscription_id = "${var.azure_subscription_id}"
  client_id       = "${var.azure_client_id}"
  client_secret   = "${var.azure_client_secret}"
  tenant_id       = "${var.azure_tenant_id}"
  version = "~> 1.10"
}

#================================================================
# Random Provider
#================================================================

provider "random" {
  version = "~> 1.3"
}
