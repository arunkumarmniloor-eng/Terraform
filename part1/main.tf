provider "aws" {
  region = var.region
}

resource "aws_instance" "app_server" {
  ami             = var.ami
  instance_type   = "t3.micro"
  key_name        = var.key_name
  # Use vpc_security_group_ids for better compatibility
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = file("userdata.sh")

  tags = {
    Name = "Flask-Express-Single-EC2"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "app-sg-unique" # Renamed to avoid conflicts if old one exists
  description = "Allow SSH and App ports"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Express Port
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Flask Port
  ingress {
    from_port   = 5000
    to_port     = 5000
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

