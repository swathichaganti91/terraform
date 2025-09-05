#######################
# Backend Launch Template
#######################
resource "aws_launch_template" "backend_lt" {
  name_prefix   = "backend-lt"
  image_id      = var.backend_ami
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.vpc_sg_id]
  }
}

#######################
# Backend Target Group
#######################
resource "aws_lb_target_group" "backend_tg" {
  name     = "backend-tg"
  port     = 80        # Changed to 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

#######################
# Backend Auto Scaling Group
#######################
resource "aws_autoscaling_group" "backend_asg" {
  desired_capacity    = 1
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = var.backend_private_subnets

  launch_template {
    id      = aws_launch_template.backend_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.backend_tg.arn]
}

#######################
# Backend ALB
#######################
resource "aws_lb" "backend_alb" {
  name               = "backend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.vpc_sg_id]
  subnets            = var.backend_private_subnets
}

#######################
# Backend Listener
#######################
resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = 80       # Changed to 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}
