terraform {
  required_providers {
    aws ={}
  }
}

provider "aws" {
  region = "us-east-1"
}

# Liberar a porta 22
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Liberar a porta 80
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http inbound"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "remote_web" {
  ami = "ami-048f6ed62451373d9"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.allow_ssh.name, aws_security_group.allow_http.name]
  key_name = "minhachavepessoal"

  provisioner "remote-exec" {
      inline = [
        "sudo yum install httpd -y",
        "sudo systemctl enable httpd.service",
        "sudo systemctl start httpd.service"
      ]

    connection {
        type = "ssh"
        user = "ec2-user"
        private_key = file("~/.ssh/id_rsa")
        host = self.public_ip
    }
  }
  tags = {
    "Name" = "Remote"
  }
}

output "ip_publico_webserver" {
  value = aws_instance.remote_web.public_ip
}