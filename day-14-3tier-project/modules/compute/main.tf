resource "aws_launch_template" "backend_lt" {
    name_prefix = "lt"
    image_id = var.ami_id
    instance_type = var.instance_type

    user_data = base64encode(<<-EOF
                #!/bin/bash
                yum update -y
                yum install git -y
                cd /root
                if [ ! -d "2nd10WeeksofCloudOps-main" ]; then
                git clone https://github.com/<your-repo>/2nd10WeeksofCloudOps-main.git
                cd repo/backend

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
resource "aws_lb_target_group" "backend_tg" {
    name = "backend-tg"
    port = 3000
    protocol = "HTTP"
    vpc_id = module.vpc.vpc_id
  
}
resource "aws_autoscaling_group" "backend_asg" {
    desired_capacity = 1
    max_size = 3
    min_size = 1
    vpc_zone_identifier = [module.vpc.private_subnet_ids[7],
                           module.vpc.private_subnet_ids[8]
    ]
    launch_template {
      id = aws_launch_template.backend_lt.id
      version = "$latest"
    }
    target_group_arns = [aws_lb_target_group.backend_tg.arn]
  
}
resource "aws_launch_template" "frontend_lt" {
    name_prefix = "frontend-lt"
    image_id = "ami-0861f4e788f5069dd"
    instance_type = var.instance_type

    user_data = base64encode(<<-EOF
                #!/bin/bash
                yum update -y
                yum install -y git httpd nodejs npm
                
                cd/home/ec2-user
                git clone https://github.com/your/repo.git
                cd repo/client
                
                echo "const backendUrl='http://${aws_lb.app_alb.dns.name}'" > src/pages/config.js
                
                npm install
                npm run build
                
                cp -r build/* /var/www/html
                systemctl enable httpd
                syatemctl start httpd
                EOF
                )

                network_interfaces {
                  associate_public_ip_address = true
                  security_groups = [module.vpc.sg_id]
                }
  
}


#######frontend launch template#####

resource "aws_launch_template" "frontend_lt" {
    name_prefix = "frontend-lt"
    image_id = "ami-0861f4e788f5069dd"
    instance_type = var.instance_type

    user_data = base64encode(<<-EOF
                #!/bin/bash
                yum install -y git httpd nodejs npm
                
                cd /home/ec2-user
                git clone https://github.com/your/repo.git
                cd repo/client
                
                echo "cons backendUrl='http://${aws_lb.app_alb.dns_name}'" > srd/pages/config.js
                
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
resource "aws_lb_target_group" "fontend_tg" {
    name = "frontend-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = module.vpc.vpc_id
  
}

resource "aws_lb_target_group" "frontend_tg" {
    name = "frontend-tg"
    port = 80
    protocol = "http"
    vpc_id = module.vpc.vpc_id
  
}

resource "aws_autoscaling_group" "frontend_asg" {
    desired_capacity = 1
    max_size = 2
    min_size = 1
    vpc_zone_identifier = [module.vpc.private_subnet_ids[5], module.vpc.private_subnet_ids[6]]

    launch_template {
      id = aws_launch_template.frontend_lt.id
      version = "$Latest"

    }
    target_group_arns = [aws_lb_target_group.fontend_tg.arn]
  
}


########## ALB + Listeners #########

resource "aws_lb" "app_alb" {
    name = "app-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [module.vpc.sg_id]
    subnets = module.vpc.public_subnet_ids
}
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
resource "aws_lb_listener_rule" "backend_rule" {
    listener_arn = aws_lb_listener.backend_listener.arn
    priority = 1

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