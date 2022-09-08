# vim main.tf

module "vpc" {
    
  source = "/home/ec2-user/06/vpc-module/"
  vpc_cidr = var.project_vpc_cidr
  project  = var.project_name
  env      = var.project_env
}

output "vpc_module_return" {
    
  value = module.vpc
}
#---------------


# Creating Security Group For bastion

resource "aws_security_group" "bastion" {
 name_prefix        = "bastion-${var.project_name}-${var.project_env}-"
  description = "Allow 22"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "allow 22"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
   
    tags = {
    
    Name = "bastion-${var.project_name}-${var.project_env}"
    project = var.project_name
    env = var.project_env
}
}


# Creating Security Group For frontend

resource "aws_security_group" "frontend" {
 name_prefix        = "frontend-${var.project_name}-${var.project_env}-"
  description = "Allow 22,80,443"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "allow 22"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }
    
     ingress {
    description      = "allow 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
    
     ingress {
    description      = "allow 443"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
    

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
   
    tags = {
    
    Name = "frontend-${var.project_name}-${var.project_env}"
    project = var.project_name
    env = var.project_env
}
}

# Creating Security Group For backend

resource "aws_security_group" "backend" {
 name_prefix        = "backend-${var.project_name}-${var.project_env}-"
  description = "Allow 22,3306"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "allow 22"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }
    
     ingress {
    description      = "allow 3306"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups = [aws_security_group.frontend.id]
  }
    
      egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
   
    tags = {
    
    Name = "backend-${var.project_name}-${var.project_env}"
    project = var.project_name
    env = var.project_env
}
}



# creating key pair

resource "aws_key_pair" "key" {
  key_name   = "${var.project_name}-${var.project_env}"
  public_key = file("localkey.pub")
    
    tags = {
    
    Name = "${var.project_name}-${var.project_env}"
    project = var.project_name
    env = var.project_env
}
}

#creating bastion instance

resource "aws_instance" "bastion" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name = aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id = module.vpc.public1_subnet_id
  user_data_replace_on_change = true
    
    
 tags = {
    
    Name = "Bastion-${var.project_name}-${var.project_env}"
    project = var.project_name
    env = var.project_env
}
}

#creating front end instance

resource "aws_instance" "frontend" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name = aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.frontend.id]
  subnet_id = module.vpc.public2_subnet_id
  user_data_replace_on_change = true
    
    
 tags = {
    
    Name = "Frontend-${var.project_name}-${var.project_env}"
    project = var.project_name
    env = var.project_env
}
}



#creating backend instance


resource "aws_instance" "backend" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name = aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.backend.id]
  subnet_id = module.vpc.private1_subnet_id
  user_data_replace_on_change = true
    
    
 tags = {
    
    Name = "backend-${var.project_name}-${var.project_env}"
    project = var.project_name
    env = var.project_env
}
}


