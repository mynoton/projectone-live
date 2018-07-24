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
# Web Server Cluster with Auto Scaling Group
#================================================================

module "webserver_cluster" {
  source = "git::https://github.com/mynoton/projectone-module.git//modules/aws_asg?ref=v0.0.8"

  ami         = "${data.aws_ami.ubuntu.id}"
  server_text = "New server text"

  aws_region             = "${var.aws_region}"
  cluster_name           = "${var.cluster_name}"

  instance_type      = "t2.micro"
  min_size           = 2
  max_size           = 4
  enable_autoscaling = false
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
}
