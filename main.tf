terraform {
  backend "s3" {
    bucket       = "mcpavao-tfstate-2026"
    key          = "terraform-aws-nginx/terraform.tfstate"
    region       = "eu-west-3"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = "eu-west-3"
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

data "aws_security_group" "mateus" {
  name = "default"
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.aws_security_group.mateus.id]

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y docker
    systemctl enable --now docker
    docker run -d -p 80:80 --restart always --name web nginx
  EOF

  tags = {
    Name = "tf-nginx-demo"
  }
}

output "public_ip" {
  value = aws_instance.web.public_ip
}