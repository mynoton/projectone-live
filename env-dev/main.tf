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
#  source             = "git::https://github.com/mynoton/projectone-module.git//modules/aws_asg?ref=v0.0.8"
#  ami                = "${data.aws_ami.ubuntu.id}"
#  server_text        = "New server text"
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

module "azure_resource_group_a" {
  source                  = "git::https://github.com/mynoton/projectone-module.git//modules/azure_resource_group"
  resource_group_name     = "ProjectOne-A-DEV"
  resource_group_location = "Southeast Asia"
  resource_group_tag_name = "ProjectOne-A-DEV"
}

module "azure_resource_group_b" {
  source                  = "git::https://github.com/mynoton/projectone-module.git//modules/azure_resource_group"
  resource_group_name     = "ProjectTwo-B-DEV"
  resource_group_location = "Southeast Asia"
  resource_group_tag_name = "ProjectOne-B-DEV"
}

#================================================================
# Azure Virtual Network Provisioning
#================================================================

module "azure_virtual_network" {
  source                  = "git::https://github.com/mynoton/projectone-module.git//modules/azure_virtual_network"
  vnw_name                = "VNW ProjectOne DEV"
  vnw_address             = "10.0.0.0/16"
  vnw_location            = "Southeast Asia"
  vnw_tag_env             = "VNW ProjectOne DEV"
  vnw_resource_group_name = "${module.azure_resource_group_a.resource_group_name_output}"
}

#================================================================
# Azure Subnet Provisioning
#================================================================

module "azure_subnet_app" {
  source                      = "git::https://github.com/mynoton/projectone-module.git//modules/azure_subnet"
  subnet_name                 = "Subnet ProjectOne APP DEV"
  subnet_resource_group_name  = "${module.azure_resource_group_a.resource_group_name_output}"
  subnet_virtual_network_name = "${module.azure_virtual_network.virtual_network_name_output}"
  subnet_address              = "10.0.2.0/24"
}

module "azure_subnet_db" {
  source                      = "git::https://github.com/mynoton/projectone-module.git//modules/azure_subnet"
  subnet_name                 = "Subnet ProjectOne DB DEV"
  subnet_resource_group_name  = "${module.azure_resource_group_a.resource_group_name_output}"
  subnet_virtual_network_name = "${module.azure_virtual_network.virtual_network_name_output}"
  subnet_address              = "10.0.3.0/24"
}

#================================================================
# Azure Public IP Provisioning
#================================================================

module "azure_public_ip_app1" {
  source                        = "git::https://github.com/mynoton/projectone-module.git//modules/azure_public_ip"
  public_ip_name                = "Public IP ProjectOne APP1 DEV"
  public_ip_location            = "Southeast Asia"
  public_ip_resource_group_name = "${module.azure_resource_group_a.resource_group_name_output}"
  public_ip_type                = "static"
  public_ip_tag_environment     = "Public IP ProjectOne APP1 DEV"
}

module "azure_public_ip_app2" {
  source                        = "git::https://github.com/mynoton/projectone-module.git//modules/azure_public_ip"
  public_ip_name                = "Public IP ProjectOne APP2 DEV"
  public_ip_location            = "Southeast Asia"
  public_ip_resource_group_name = "${module.azure_resource_group_a.resource_group_name_output}"
  public_ip_type                = "static"
  public_ip_tag_environment     = "Public IP ProjectOne APP2 DEV"
}

module "azure_public_ip_db1" {
  source                        = "git::https://github.com/mynoton/projectone-module.git//modules/azure_public_ip"
  public_ip_name                = "Public IP ProjectOne DB1 DEV"
  public_ip_location            = "Southeast Asia"
  public_ip_resource_group_name = "${module.azure_resource_group_a.resource_group_name_output}"
  public_ip_type                = "static"
  public_ip_tag_environment     = "Public IP ProjectOne DB1 DEV"
}

module "azure_public_ip_db2" {
  source                        = "git::https://github.com/mynoton/projectone-module.git//modules/azure_public_ip"
  public_ip_name                = "Public IP ProjectOne DB2 DEV"
  public_ip_location            = "Southeast Asia"
  public_ip_resource_group_name = "${module.azure_resource_group_a.resource_group_name_output}"
  public_ip_type                = "static"
  public_ip_tag_environment     = "Public IP ProjectOne DB2 DEV"
}

#================================================================
# Azure Network Security Group Provisioning
#================================================================

module "azure_network_security_group" {
  source                         = "git::https://github.com/mynoton/projectone-module.git//modules/azure_network_security_group"
  nw_sg_name                     = "NW-SG SSH ProjectOne DEV"
  nw_sg_location                 = "Southeast Asia"
  nw_sg_resource_group_name      = "${module.azure_resource_group_a.resource_group_name_output}"
  nw_sg_rule_name                = "SSH"
  nw_sg_rule_priority            = 1001
  nw_sg_rule_direction           = "Inbound"
  nw_sg_rule_access              = "Allow"
  nw_sg_rule_protocol            = "Tcp"
  nw_sg_rule_src_port_range      = "*"
  nw_sg_rule_dest_port_range     = "22"
  nw_sg_rule_src_address_prefix  = "*"
  nw_sg_rule_dest_address_prefix = "*"
  nw_sg_tag_env                  = "NW-SG SSH ProjectOne DEV"
}

#================================================================
# Azure Virtual Network Interface Provisioning
#================================================================

module "azure_virtual_network_interface_app1" {
  source                    = "git::https://github.com/mynoton/projectone-module.git//modules/azure_virtual_network_interface"
  vnic_name                 = "VNIC APP1 ProjectOne DEV"
  vnic_location             = "Southeast Asia"
  vnic_resource_group_name  = "${module.azure_resource_group_a.resource_group_name_output}"
  vnic_conf_name            = "VNIC APP1 ProjectOne DEV Configuration"
  vnic_conf_subnet_id       = "${module.azure_subnet_app.subnet_id_output}"
  vnic_conf_private_ip_type = "static"
  vnic_conf_public_ip_id    = "${module.azure_public_ip_app1.public_ip_id_output}"
  vnic_tag_env              = "VNIC APP1 ProjectOne DEV"
}

module "azure_virtual_network_interface_app2" {
  source                    = "git::https://github.com/mynoton/projectone-module.git//modules/azure_virtual_network_interface"
  vnic_name                 = "VNIC APP2 ProjectOne DEV"
  vnic_location             = "Southeast Asia"
  vnic_resource_group_name  = "${module.azure_resource_group_a.resource_group_name_output}"
  vnic_conf_name            = "VNIC APP2 ProjectOne DEV Configuration"
  vnic_conf_subnet_id       = "${module.azure_subnet_app.subnet_id_output}"
  vnic_conf_private_ip_type = "static"
  vnic_conf_public_ip_id    = "${module.azure_public_ip_app2.public_ip_id_output}"
  vnic_tag_env              = "VNIC APP2 ProjectOne DEV"
}

module "azure_virtual_network_interface_db1" {
  source                    = "git::https://github.com/mynoton/projectone-module.git//modules/azure_virtual_network_interface"
  vnic_name                 = "VNIC DB1 ProjectOne DEV"
  vnic_location             = "Southeast Asia"
  vnic_resource_group_name  = "${module.azure_resource_group_a.resource_group_name_output}"
  vnic_conf_name            = "VNIC DB2 ProjectOne DEV Configuration"
  vnic_conf_subnet_id       = "${module.azure_subnet_app.subnet_id_output}"
  vnic_conf_private_ip_type = "static"
  vnic_conf_public_ip_id    = "${module.azure_public_ip_db1.public_ip_id_output}"
  vnic_tag_env              = "VNIC DB1 ProjectOne DEV"
}

module "azure_virtual_network_interface_db2" {
  source                    = "git::https://github.com/mynoton/projectone-module.git//modules/azure_virtual_network_interface"
  vnic_name                 = "VNIC DB2 ProjectOne DEV"
  vnic_location             = "Southeast Asia"
  vnic_resource_group_name  = "${module.azure_resource_group_a.resource_group_name_output}"
  vnic_conf_name            = "VNIC DB2 ProjectOne DEV Configuration"
  vnic_conf_subnet_id       = "${module.azure_subnet_app.subnet_id_output}"
  vnic_conf_private_ip_type = "static"
  vnic_conf_public_ip_id    = "${module.azure_public_ip_db2.public_ip_id_output}"
  vnic_tag_env              = "VNIC DB2 ProjectOne DEV"
}

#================================================================
# Azure Storage Account Provisioning for Boot Diagnostic
#================================================================

module "storage_account_boot_diagnostic" {
  source                              = "git::https://github.com/mynoton/projectone-module.git//modules/azure_storage_account_boot_diagnostic"
  random_id_resource_group_name       = "${module.azure_resource_group_a.resource_group_name_output}"
  storage_account_resource_group_name = "${module.azure_resource_group_a.resource_group_name_output}"
  storage_account_location            = "Southeast Asia"
  storage_account_rep_type            = "LRS"
  storage_account_tier                = "Standard"
  storage_account_tag_env             = "Storage Account Boot Diagnostic ProjectOne DEV"
}
