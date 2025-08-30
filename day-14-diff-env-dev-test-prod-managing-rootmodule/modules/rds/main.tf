data "aws_secretsmanager_secret" "db" {
    name = "swathisecrets"
  
}
data "aws_secretsmanager_secret_version" "db" {
    secret_id = data.aws_secretsmanager_secret.db.id
  
}
locals {
  db_secret = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)
}

resource "aws_db_instance" "rds" {
    identifier = var.db_identifier
    allocated_storage = var.allocated_storage
    engine = var.engine
    engine_version = "8.0"
    instance_class = var.db_instance_class
    db_name = var.db_name
    username = local.db_secret["username"]
    password = local.db_secret["password"]
    db_subnet_group_name = module.vpc.db_subnet_group_name
    vpc_security_group_ids = [module.vpc.sg_id]
}
resource "null_resource" "run_sql" {
    depends_on = [ aws_db_instance.rds, aws_instance.backend ]
    provisioner "file" {
        source = "${path.module}/test.sql"
        destination = "/tmp/test.sql"

        connection {
          type = "ssh"
          user = "ec2-  user"
          private_key = file("~/.ssh/id_rsa")
          host = aws_instance.backend.public_ip
          
        }
      
    }
    provisioner "remote-exec" {
        inline = [ 
            "mysql -h ${aws_db_instance.rds.address} -u ${local.db_secret["username"]} -p${local.db_secret["password"]} < /tmp/test.sql"
         ]
         connection {
             type = "ssh"
             user = "ec2-user"
             private_key = file("~/.ssh/id_rsa")
             host = aws_instance.backend.public_ip
         }
    }
  
}

  

