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

variable "public_key" {
  description = "SSH public key content used for EC2 access"
  type        = string
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

resource "aws_key_pair" "mateus" {
  key_name   = "mateus-key"
  public_key = var.public_key
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.aws_security_group.mateus.id]
  key_name               = aws_key_pair.mateus.key_name

  tags = {
    Name = "tf-nginx-demo"
  }
}

output "public_ip" {
  value = aws_instance.web.public_ip
}