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
  source                   = "git::https://github.com/mynoton/projectone-module.git//modules/azure_virtual_network"
  vnet_name                = "VNW ProjectOne DEV"
  vnet_address             = "10.0.0.0/16"
  vnet_location            = "Southeast Asia"
  vnet_tag_env             = "VNW ProjectOne DEV"
  vnet_resource_group_name = "${module.azure_resource_group_a.resource_group_name_output}"
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

module "azure_public_ip" {
  source                        = "git::https://github.com/mynoton/projectone-module.git//modules/azure_public_ip"
  public_ip_name                = "Public IP ProjectOne DEV"
  public_ip_location            = "Southeast Asia"
  public_ip_resource_group_name = "${module.azure_resource_group_a.resource_group_name_output}"
  public_ip_type                = "static"
  public_ip_dns_name            = "projectonedev"
  public_ip_tag_environment     = "Public IP ProjectOne DEV"
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

module "azure_virtual_network_interface_app" {
  source                       = "git::https://github.com/mynoton/projectone-module.git//modules/azure_virtual_network_interface"
  vnic_name                    = "VNIC-APP-ProjectOne-DEV"
  vnic_location                = "Southeast Asia"
  vnic_resource_group_name     = "${module.azure_resource_group_a.resource_group_name_output}"
  vnic_count                   = 2
  vnic_conf_name               = "VNIC-APP-ProjectOne-DEV-Configuration"
  vnic_conf_subnet_id          = "${module.azure_subnet_app.subnet_id_output}"
  vnic_conf_private_ip_type    = "static"
  #vnic_conf_public_ip_id      = "${module.azure_public_ip_app.public_ip_id_output}"
  vnic_conf_lb_bk_address_pool = "${module.azure_loadbalancer.lb_backend_address_pool_id_output}"
  vnic_conf_lb_nat_rule_id     = "${module.azure_loadbalancer.azurerm_lb_nat_rule_id}" 
  vnic_tag_env                 = "VNIC-APP-ProjectOne-DEV"
}

module "azure_virtual_network_interface_db" {
  source                       = "git::https://github.com/mynoton/projectone-module.git//modules/azure_virtual_network_interface"
  vnic_name                    = "VNIC-DB-ProjectOne-DEV"
  vnic_location                = "Southeast Asia"
  vnic_resource_group_name     = "${module.azure_resource_group_a.resource_group_name_output}"
  vnic_count                   = 2
  vnic_conf_name               = "VNIC-DB-ProjectOne-DEV-Configuration"
  vnic_conf_subnet_id          = "${module.azure_subnet_db.subnet_id_output}"
  vnic_conf_private_ip_type    = "static"
  #vnic_conf_public_ip_id      = "${module.azure_public_ip_db.public_ip_id_output}"
  vnic_conf_lb_bk_address_pool = "${module.azure_loadbalancer.lb_backend_address_pool_id_output}"
  vnic_conf_lb_nat_rule_id     = "${module.azure_loadbalancer.azurerm_lb_nat_rule_id}"
  vnic_tag_env                 = "VNIC-DB-ProjectOne-DEV"
}

#================================================================
# Azure Storage Account Provisioning for Boot Diagnostic
#================================================================

module "azure_storage_account_boot_diagnostic" {
  source                              = "git::https://github.com/mynoton/projectone-module.git//modules/azure_storage_account_boot_diagnostic"
  random_id_resource_group_name       = "${module.azure_resource_group_a.resource_group_name_output}"
  storage_account_resource_group_name = "${module.azure_resource_group_a.resource_group_name_output}"
  storage_account_location            = "Southeast Asia"
  storage_account_rep_type            = "LRS"
  storage_account_tier                = "Standard"
  storage_account_tag_env             = "Storage Account Boot Diagnostic ProjectOne DEV"
}

#================================================================
# Azure Virtual Machine Provisioning
#================================================================

module "azure_virtual_machine_app" {
  source                     = "git::https://github.com/mynoton/projectone-module.git//modules/azure_virtual_machine_avset"
  vm_name                    = "VM-APP-DEV"
  vm_location                = "Southeast Asia"
  vm_resource_group_name     = "${module.azure_resource_group_a.resource_group_name_output}"
  vm_vnic_id                 = ["${module.azure_virtual_network_interface_app.virtual_network_interface_id_output}"]
  vm_size                    = "Standard_DS1_v2"
  vm_avset_id                = "${module.azure_availability_set.availability_set_id_output}"
  vm_instance_count          = 2
  vm_disk_name               = "VM-Disk-APP-DEV"
  vm_disk_caching            = "ReadWrite"
  vm_disk_create_option      = "FromImage"
  vm_disk_type               = "Premium_LRS"
  vm_image_publisher         = "Canonical"
  vm_image_offer             = "UbuntuServer"
  vm_image_sku               = "16.04.0-LTS"
  vm_image_version           = "latest"
  vm_profile_com_name        = "myvm"
  vm_profile_admin_username  = "azureuser"
  vm_config_sshkey_path      = "/home/azureuser/.ssh/authorized_keys"
  vm_config_sshkey_data      = "ssh-rsa AAAAB3Nz{snip}hwhqT9h"
  vm_diagnostic_storage_uri  = "${module.azure_storage_account_boot_diagnostic.storage_account_endpoint_output}"
  vm_tag_env                 = "VM-APP-DEV"
}

module "azure_virtual_machine_db" {
  source                     = "git::https://github.com/mynoton/projectone-module.git//modules/azure_virtual_machine"
  vm_name                    = "VM-DB-DEV"
  vm_location                = "Southeast Asia"
  vm_resource_group_name     = "${module.azure_resource_group_a.resource_group_name_output}"
  vm_vnic_id                 = ["${module.azure_virtual_network_interface_db.virtual_network_interface_id_output}"]
  vm_size                    = "Standard_DS1_v2"
  vm_avset_id                = "${module.azure_availability_set.availability_set_id_output}"
  vm_instance_count          = 2
  vm_disk_name               = "VM-Disk-DB-DEV"
  vm_disk_caching            = "ReadWrite"
  vm_disk_create_option      = "FromImage"
  vm_disk_type               = "Premium_LRS"
  vm_image_publisher         = "Canonical"
  vm_image_offer             = "UbuntuServer"
  vm_image_sku               = "16.04.0-LTS"
  vm_image_version           = "latest"
  vm_profile_com_name        = "myvm"
  vm_profile_admin_username  = "azureuser"
  vm_config_sshkey_path      = "/home/azureuser/.ssh/authorized_keys"
  vm_config_sshkey_data      = "ssh-rsa AAAAB3Nz{snip}hwhqT9h"
  vm_diagnostic_storage_uri  = "${module.azure_storage_account_boot_diagnostic.storage_account_endpoint_output}"
  vm_tag_env                 = "VM-DB-DEV"
}

#================================================================
# Azure Virtual Machine Provisioning
#================================================================

module "azure_availability_set" {
  source                    = "git::https://github.com/mynoton/projectone-module.git//modules/azure_availability_set"
  avset_name                = "Availability Set ProjectOne DEV"
  avset_location            = "Southeast Asia"
  avset_resource_group_name = "${module.azure_resource_group_a.resource_group_name_output}"
  avset_fault_count         = 2
  avset_update_count        = 2
  avset_management          = true
}

#================================================================
# Azure Load Balancer Provisioning
#================================================================

module "azure_loadbalancer" {
  source                                 = "git::https://github.com/mynoton/projectone-module.git//modules/azure_loadbalancer"
  lb_resource_group_name                 = "${module.azure_resource_group_a.resource_group_name_output}"
  lb_name                                = "LB-ProjectOne-DEV"
  lb_location                            = "Southeast Asia"
  lb_fe_conf_name                        = "LB-FE-ProjectOne-DEV"
  lb_fe_conf_public_ip_id                = "${module.azure_public_ip.public_ip_id_output}"
  lb_bk_address_pool_resource_group_name = "${module.azure_resource_group_a.resource_group_name_output}"
  lb_bk_address_pool_name                = "LB-BKPool-ProjectOne-DEV"
  lb_nat_rule_resource_group_name        = "${module.azure_resource_group_a.resource_group_name_output}"
  lb_nat_rule_name                       = "LB-NAT-RDP-VM-ProjectOne-DEV"
  lb_nat_rule_protocol                   = "tcp"
  # frontend port + count
  lb_nat_rule_fe_port                    = "5000"
  lb_nat_rule_bk_port                    = 3389
  lb_nat_rule_fe_conf_name               = "LB-NAT-FE-Rule-ProjectOne-DEV"
  lb_nat_rule_count                      = 2
  lb_rule_resource_group_name            = "${module.azure_resource_group_a.resource_group_name_output}"
  lb_rule_name                           = "LB-Rule-ProjectOne-DEV"
  lb_rule_protocol                       = "tcp"
  lb_rule_fe_port                        = "80"
  lb_rule_bk_port                        = "80"
  lb_rule_fe_conf_name                   = "LB-FE-Rule-ProjectOne-DEV"
  lb_rule_enable_floating_ip             = false
  lb_rule_idle_timeout_in_minutes        = 5
  lb_probe_resource_group_name           = "${module.azure_resource_group_a.resource_group_name_output}"
  lb_probe_name                          = "LB-TCP-Probe"
  lb_probe_protocol                      = "tcp"
  lb_probe_port                          = 80
  lb_probe_interval_sec                  = 5
  lb_probe_number_probe                  = 2
}

