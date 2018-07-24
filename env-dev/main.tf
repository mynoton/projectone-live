#================================================================
# Specify Terraform Version
#================================================================

terraform {
  required_version = ">= 0.11, < 0.12"
}

#================================================================
# Terraform Configuration
#================================================================

#terraform {
#  backend "s3" {
#    encrypt        = true
#    bucket         = "${var.remote_state}"
#    dynamodb_table = "${var.remote_state_lock}"
#    key            = "${var.remote_state_key}"
#  }
#}

#================================================================
# AWS Web Server Cluster with Auto Scaling Group
#================================================================

#module "aws_webserver_cluster" {
#  source = "git::https://github.com/mynoton/projectone-module.git//modules/aws_asg?ref=v0.0.8"
#  ami         = "${data.aws_ami.ubuntu.id}"
#  server_text = "New server text"
#  aws_region         = "${var.aws_region}"
#  cluster_name       = "${var.cluster_name}"
#  instance_type      = "t2.micro"
#  min_size           = 2
#  max_size           = 4
#  enable_autoscaling = false
#}

#================================================================
# Azure Resource Group Provisioning
#================================================================

module "azure_resource_group" {
  source = "git::https://github.com/mynoton/projectone-module.git//modules/azure_resource_group?ref=v0.0.13"
  resource_group_name = "ProjectOne"
  resource_group_location = "Southeast Asia"
  resource_group_tag_name = "ProjectOne"
}

#================================================================
# Azure Virtual Network Provisioning
#================================================================

module "azure_virtual_network" {
  source = "git::https://github.com/mynoton/projectone-module.git//modules/azure_virtual_network?ref=v0.0.13"
  vnw_name = "VNW ProjectOne Dev"
  vnw_address = "10.0.0.0/16"
  vnw_location = "Southeast Asia"
  vnw_tag_env = "ProjectOne"
  resource_group_name = "${module.azure_resource_group.resource_group_name_output}"
}
