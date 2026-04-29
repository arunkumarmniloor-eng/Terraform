provider "aws" {
  region = var.region
}

resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "part2-vpc" }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = { Name = "part2-public-subnet" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Express SG (Port 3000)
resource "aws_security_group" "express_sg" {
  name   = "express-sg"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

# Flask SG (Port 5000)
resource "aws_security_group" "flask_sg" {
  name   = "flask-sg"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.express_sg.id]
  }

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

# Flask Backend Instance
resource "aws_instance" "flask_app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.flask_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y python3-pip
              pip3 install flask
              echo "from flask import Flask; app = Flask(__name__); @app.route('/')
              def hello(): return 'Flask Backend Instance Running'
              if __name__ == '__main__': app.run(host='0.0.0.0', port=5000)" > /home/ubuntu/app.py
              nohup python3 /home/ubuntu/app.py &
              EOF

  tags = { Name = "Flask-Backend" }
}

# Express Frontend Instance
resource "aws_instance" "express_app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.express_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              curl -fsSL https://nodesource.com | bash -
              apt-get install -y nodejs
              mkdir -p /home/ubuntu/express && cd /home/ubuntu/express
              npm init -y && npm install express
              echo \"const express = require('express'); const app = express(); app.get('/', (req, res) => res.send('Express Frontend Instance Running')); app.listen(3000, '0.0.0.0');\" > index.js
              nohup node index.js &
              EOF

  tags = { Name = "Express-Frontend" }
}

