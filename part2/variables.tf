variable "region" { default = "us-east-1" }
variable "ami_id" { default = "ami-5c7217cdde317cfec" } # Ubuntu 22.04 LTS
variable "instance_type" { default = "t3.micro" }
variable "key_name" { description = "Name of your existing EC2 Key Pair" }

