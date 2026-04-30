## AWS Multi-Tier Deployment with Terraform
This repository contains the infrastructure-as-code (IaC) configuration to deploy a Flask backend and an Express frontend application on AWS using three different architectural patterns.
## 🚀 Project Overview

* Part 1: Single EC2 Instance hosting both applications.
* Part 2: Two separate EC2 Instances in a custom VPC with security group peering.
* Part 3: Containerized deployment using AWS ECR, ECS (Fargate), and an Application Load Balancer (ALB).

------------------------------
## 📂 Repository Structure

├── part1/              # Terraform for Single EC2 deployment
├── part2/              # Terraform for Multi-EC2 VPC deployment
├── part3/              # Terraform for ECS Fargate & ALB deployment
├── flask/              # Backend application source code & Dockerfile
└── express/            # Frontend application source code & Dockerfile

------------------------------
## 🛠 Prerequisites

* AWS CLI configured with appropriate credentials.
* Terraform installed.
* Docker installed (for Part 3).
* An existing EC2 Key Pair.

------------------------------
## 📖 Deployment Instructions## Part 1: Single EC2 Instance

   1. Navigate to the directory: cd part1
   2. Initialize Terraform: terraform init
   3. Deploy: terraform apply -var="key_name=YOUR_KEY_NAME"
   4. Access the apps:
   * Frontend: http://<public_ip>:3000
      * Backend: http://<public_ip>:5000
   
## Part 2: Separate EC2 Instances

   1. Navigate to the directory: cd part2
   2. Initialize and Apply: terraform init && terraform apply
   3. Note: The Flask instance is isolated; it only accepts traffic from the Express instance on port 5000.

## Part 3: ECS Fargate & Docker

   1. Infrastructure:
   * Navigate to cd part3.
      * Run terraform init and terraform apply.
   2. ECR Login:
   * Get the login command from the AWS Console or use:
      * aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account_id>.dkr.ecr.<region>.amazonaws.com
   3. Push Images:
   * Build, tag, and push your Flask and Express images to the ECR URLs provided in the terraform outputs.
   4. Access:
   * Use the alb_dns_name output to visit the application in your browser.
   
------------------------------
## ⚙️ Key AWS Services Used

* EC2: Virtual servers for hosting applications.
* VPC: Custom networking with public/private subnets and route tables.
* ECR: Private Docker registry to store container images.
* ECS Fargate: Serverless container orchestration.
* ALB: Load balancing and path-based routing.
* IAM: Roles for ECS task execution and ECR access.

------------------------------
## 🧹 Cleanup
To avoid ongoing AWS charges, destroy the infrastructure in each folder:

terraform destroy
Would you like me to help you format the specific "Project Deliverables" section for your Google Doc submission?

