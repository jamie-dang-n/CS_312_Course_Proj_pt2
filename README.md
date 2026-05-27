# Background
This project fully automates the provisioning, configuring, and setup of a Minecraft server using a Docker image and Terraform on AWS ECS. This project follows the tutorial given by \[1\], with cost-lowering revisions by \[2\]. 

# Requirements
For this, you will need to have:
- An AWS account
- Terraform installed
- AWS CLI installed, AWS account logged in

# Pipeline Diagram


# Commands to run
1. Run `git clone https://github.com/jamie-dang-n/CS_312_Course_Proj_pt2.git` to clone this repository.
2. CD into `CS_312_Course_Proj_pt2`. 
3. Run `terraform init` to initialize Terraform
4. Run `terraform plan` to error-check the cloned `.tf` files
5. Run `terraform apply` to spin up the Minecraft server

# Connecting to the Minecraft Server

# References
\[1\] [https://www.thelastdev.com/p/learning-ecs-the-fun-way-hosting](https://www.thelastdev.com/p/learning-ecs-the-fun-way-hosting)

\[2\] [https://github.com/czantoine/minecraft-server-aws-ecs-fargate](https://github.com/czantoine/minecraft-server-aws-ecs-fargate)