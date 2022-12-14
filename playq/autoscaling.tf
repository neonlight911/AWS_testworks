terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

############################################

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

############################################

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = var.ssh_key_name
  public_key = tls_private_key.this.public_key_openssh
}

resource "aws_default_vpc" "default" {}

resource "aws_autoscaling_group" "this" {
  health_check_grace_period = 300
  health_check_type         = "ELB"
  launch_configuration      = aws_launch_configuration.this.name
  max_size                  = 6
  min_size                  = 2
  target_group_arns         = [aws_lb_target_group.this.arn]
  vpc_zone_identifier       = data.aws_subnet_ids.default.ids
  tags                      = var.asg_tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "this" {
  image_id        = data.aws_ami.latest_amazon_linux.id
  # image_id  = lookup(var.ami, var.region)
  instance_type   = var.ec2_instance_type
  key_name        = aws_key_pair.this.key_name
  security_groups = [aws_security_group.asg.id]
  user_data       = file("userdata.sh")
  lifecycle {
    create_before_destroy = true
  }
}

############################################

output "private_key" {
  value     = tls_private_key.this.private_key_pem
  sensitive = true
}
