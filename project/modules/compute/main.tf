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
  subnets = [
    var.frontend_public_subnets[0],
    var.frontend_public_subnets[1]
  ]
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
#######################
# Frontend Launch Template
#######################
resource "aws_launch_template" "frontend_lt" {
  name_prefix   = "frontend-lt"
  image_id      = var.frontend_ami
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.vpc_sg_id]
  }
}
#######################
# Frontend Target Group
#######################
resource "aws_lb_target_group" "frontend_tg" {
  name     = "frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

#######################
# Frontend Auto Scaling Group
#######################
resource "aws_autoscaling_group" "frontend_asg" {
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = var.frontend_public_subnets

  launch_template {
    id      = aws_launch_template.frontend_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.frontend_tg.arn]
}
#######################
# Frontend ALB
#######################
resource "aws_lb" "frontend_alb" {
  name               = "frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.vpc_sg_id]
  
  # Must use at least 2 subnets in different AZs
  subnets = [
    var.frontend_public_subnets[0],
    var.frontend_public_subnets[1]
  ]
}
#######################
# Frontend Listener
#######################
resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

