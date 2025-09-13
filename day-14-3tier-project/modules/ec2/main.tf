#resource "aws_key_pair" "my_key" {
 # key_name   = "my-ec2-keypair"                      # Name in AWS
 # public_key = file("~/.ssh/id_rsa.pub")             # Your local public key
#}
#data "template_file" "backend_userdata" {
#  template = file("${path.module}/backend_userdata.sh.tpl")

#  vars = {
#    db_endpoint = module.rds.db_endpoint
#    db_pass     = module.rds.db_pass
#    db_name     = module.rds.db_name
#  }
#}

#resource "aws_instance" "backend" {
 # ami                    =  "ami-0861f4e788f5069dd" # change
 # instance_type          = "t3.micro"
 # key_name = "my-ec2-keypair"
 # subnet_id              = module.vpc.private_subnet_ids[5]
 # vpc_security_group_ids = [module.vpc.sg_id]

  #user_data = data.template_file.backend_userdata.rendered
#}








######frontend########
#resource "aws_instance" "frontend" {
#  ami           = "ami-0861f4e788f5069dd"      # Amazon Linux 2023 or 2
#  instance_type = "t3.micro"
#  subnet_id = module.vpc.public_subnet_ids[1]
#  key_name      = "my-ec2-keypair"
#  vpc_security_group_ids = [module.vpc.sg.id]
#  public_ip = true

 # user_data = <<-EOF
    #!/bin/bash
  #  yum update -y
  #  yum install -y git httpd
  #  dnf install -y nodejs

    # clone project
  #  cd /home/ec2-user
  #  git clone https://github.com/your/repo.git
  #  cd 2nd10WeeksofCloudOps-main/client

    # configure backend URL
   # echo 'const config = { backendUrl: "http://${aws_instance.backend.public_ip}:3000" }; export default config;' > src/pages/config.js

    # build React app
   # npm install
   # npm run build

    # deploy build to Apache
   # cp -r build/* /var/www/html

    # start Apache
   # systemctl enable httpd
   # systemctl restart httpd
  #EOF

  #tags = {
  #  Name = "frontend-ec2"
  #}
#}

# Frontend AMI
# Frontend AMI



resource "aws_instance" "bastion" {
  ami                    = "ami-0fe4e90accd5cc34a"
  instance_type          = "t3.micro"
  key_name               = var.key_name
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [var.sg_id]

  tags = { Name = "bastion-ec2" }
}

resource "aws_instance" "frontend" {
  ami                    = var.frontend_ami   # <-- FIXED
  instance_type          = "t3.micro"
  key_name               = var.key_name
  subnet_id              = var.public_subnet_ids[1]
  vpc_security_group_ids = [var.sg_id]

  tags = { Name = "frontend-ec2" }
}

resource "aws_instance" "backend" {
  ami                    = var.backend_ami    # <-- FIXED
  instance_type          = "t3.micro"
  key_name               = var.key_name
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [var.sg_id]

  tags = { Name = "backend-ec2" }
}
