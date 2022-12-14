variable "region" {
    default = "us-east-1"
}

variable "project" {
    default = "playq-2019"
}

variable "management_ips" {
    type = list(string)
    description = "Allowed IP adresses"
    default = [
        "76.169.181.157"
    ]
}

variable "ssh_key_name" {
  type        = string
  description = "The name of the key pair"
  default     = "webservers"
}

variable "ec2_instance_type" {
  type = string
  default = "t2.micro"
}

variable "myip_resolver" {
  type = string
  description = "HTTP public MYIP resolver URL"
  default = "http://ipv4.icanhazip.com"
}

# variable "ami" {
#     default = {
#         us-east-1 = "ami-03e0b06f01d45a4eb"
#         us-west-1 = "ami-0af7a5885e3ff0439"
#     }
# }

variable "asg_tags" {
  default = [
    {
      key                 = "Name"
      value               = "PlayQ-2019"
      propagate_at_launch = true
    },
    {
      key                 = "Type"
      value               = "webserver"
      propagate_at_launch = true
    },
  ]
}
