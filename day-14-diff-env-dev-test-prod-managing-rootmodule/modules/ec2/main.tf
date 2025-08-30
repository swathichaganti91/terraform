


data "template_file" "backend_userdata" {
  template = file("${path.module}/backend_userdata.sh.tpl")

  vars = {
    db_endpoint = module.rds.db_endpoint
    db_user     = module.rds.db_user
    db_pass     = module.rds.db_pass
    db_name     = module.rds.db_name
  }
}

resource "aws_instance" "backend" {
  ami                    = "ami-0c123456789abcdef" # change
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.private_subnet_ids[5]
  vpc_security_group_ids = [module.vpc.sg_id]

  user_data = data.template_file.backend_userdata.rendered
}







######frontend########
resource "aws_instance" "frontend" {
  ami           = "ami-xxxxxxxx"      # Amazon Linux 2023 or 2
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private3.id
  key_name      = "~/.ssh/id_rsa.pub"
  vpc_security_group_ids = [module.vpc.aws_security_group.sg.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y git httpd
    dnf install -y nodejs

    # clone project
    cd /home/ec2-user
    git clone https://github.com/your/repo.git
    cd 2nd10WeeksofCloudOps-main/client

    # configure backend URL
    echo 'const config = { backendUrl: "http://${aws_instance.backend.public_ip}:3000" }; export default config;' > src/pages/config.js

    # build React app
    npm install
    npm run build

    # deploy build to Apache
    cp -r build/* /var/www/html

    # start Apache
    systemctl enable httpd
    systemctl restart httpd
  EOF

  tags = {
    Name = "frontend-ec2"
  }
}

