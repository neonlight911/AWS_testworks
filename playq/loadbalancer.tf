data "http" "myip" {
  url = var.myip_resolver
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

locals {
  management_all_ips = concat(var.management_ips, tolist([chomp(data.http.myip.response_body)]))
}

############################################

resource "aws_security_group" "alb" {
  name        = "alb"
  description = "Security Group for ALB"
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "asg" {
  name        = "asg"
  description = "Security Group for ASG"
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  dynamic "ingress" {
    for_each = local.management_all_ips
    content {
      description = "management address"
      from_port   = 0
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [format("%s/32", ingress.value)]
    }
  }
  ingress {
    from_port       = 80
    protocol        = "tcp"
    to_port         = 80
    security_groups = [aws_security_group.alb.id]
  }
}

resource "aws_lb" "this" {
  name               = var.project
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Internal Server Error"
      status_code  = "500"
    }
  }
}

resource "aws_lb_target_group" "this" {
  name     = "alb-tg-to-asg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
  condition {
    host_header {
      values = [
      "${aws_lb.this.name}-*.elb.amazonaws.com"]
    }
  }
  condition {
    path_pattern {
      values = ["/index.html"]
    }
  }
}

############################################

output "alb_dns_name" {
  value       = aws_lb.this.dns_name
  description = "ALB DNS name"
}
