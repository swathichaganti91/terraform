resource "aws_launch_template" "backend_lt" {
    name_prefix = "lt"
    image_id = var.backend_ami_id
    instance_type = "t3.small"

    user_data = base64encode(<<-EOF
                #!/bin/bash
                yum update -y
                yum install git -y git nodejs npm
                npm install -g pm2
                cd /root
                if [ ! -d "2nd10WeeksofCloudOps-main" ]; then
                git clone https://github.com/CloudTechDevOps/2nd10WeeksofCloudOps-main.git
                fi

                cd 2nd10WeeksofCloudOps-main/backend || {
                echo "Failed to change directory to backend. Exiting."
                exit 1
}

                echo "DB_HOST=${module.rds.db_endpoint}" >>.env
                echo "DB_USER=${module.rds.db_user}" >> .env
                echo "DB_PASS=${module.rds.db_pass}" >> .env
                echo "DB_NAME=${module.rds.db_name}" >> .env

                npm install
                pm2 start index.js --name backend-app
                EOF
              

                
                )
                network_interfaces {
                  associate_public_ip_address = true
                  security_groups = [module.vpc.sg_id]
                }
  
}
###target group backend
resource "aws_lb_target_group" "backend_tg" {
    name = "backend-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = module.vpc.vpc_id
  
}
###backend ASG
resource "aws_autoscaling_group" "backend_asg" {
    desired_capacity = 1
    max_size = 1
    min_size = 1
    vpc_zone_identifier = [module.vpc.private_subnet_ids[7],
                           module.vpc.private_subnet_ids[8]
    ]
    launch_template {
      id = aws_launch_template.backend_lt.id
      version = "Latest"
    }
    target_group_arns = [aws_lb_target_group.backend_tg.arn]
  
}
#######frontend launch template#####

resource "aws_launch_template" "frontend_lt" {
    name_prefix = "frontend-lt"
    image_id = var.frontend_ami_id
    instance_type = "t3.small"

    user_data = base64encode(<<-EOF
                #!/bin/bash
                
                yum install -y git httpd nodejs npm
                
                
                cd /home/ec2-user
                git clone https://github.com/CloudTechDevOps/2nd10WeeksofCloudOps-main.git
                cd 2nd10WeeksofCloudOps-main/client

                
                echo "const backendUrl='http://${aws_lb.app_alb.dns_name}/api'" > src/pages/config.js
                
                npm install
                npm run build
                
                cp -r build/* /var/www/html
                systemctl enable httpd
                systemctl start httpd
                EOF
                )
                network_interfaces {
                  associate_public_ip_address = true
                  security_groups = [module.vpc.sg_id]

                }

  
}
#frontend targetgroup
resource "aws_lb_target_group" "frontend_tg" {
    name = "frontend-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = module.vpc.vpc_id
  
}
##frontend ASG
resource "aws_autoscaling_group" "frontend_asg" {
    desired_capacity = 1
    max_size = 1
    min_size = 1
    vpc_zone_identifier = [module.vpc.private_subnet_ids[5], module.vpc.private_subnet_ids[6]]

    launch_template {
      id = aws_launch_template.frontend_lt.id
      version = "$Latest"

    }
    target_group_arns = [aws_lb_target_group.frontend_tg.arn]
  
}


########## ALB + Listeners #########

resource "aws_lb" "app_alb" {
    name = "app-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [module.vpc.sg_id]
    subnets = module.vpc.public_subnet_ids
}
##listener frotend
resource "aws_lb_listener" "frontend_listener" {
    load_balancer_arn = aws_lb.app_alb.arn
    port = 80
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.frontend_tg.arn

    }
}
## frontend rule
resource "aws_lb_listener_rule" "frontend_rule" {
  listener_arn = aws_lb_listener.frontend_listener.arn
  priority = 1

  action {
   type = "forward"
   target_group_arn = aws_lb_target_group.frontend_tg.arn 
  }
  


    condition {
      path_pattern {
        values = ["/app/*"]
      }
    }
  
}
##listener backend rule
resource "aws_lb_listener_rule" "backend_rule" {
    listener_arn = aws_lb_listener.frontend_listener.arn
    priority = 2

    action {
      type = "forward"
      target_group_arn = aws_lb_target_group.backend_tg.arn
    }
    condition {
      path_pattern {
        values = ["/api/*"]
      }
    }
  
}