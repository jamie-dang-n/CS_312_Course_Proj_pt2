# Background
This project fully automates the provisioning, configuring, and setup of a Minecraft server using a Docker image [\[4\]](#references) and Terraform on AWS ECS. Server data is stored on an EFS instance. This project follows the tutorial given by [\[1\]](#references), with cost-lowering revisions by [\[2\]](#references). Some modifications were made to use the provided IAM role, `LabRole`, as this project was done on AWS Learner Lab.

# Requirements
For this, you will need to have:
- An AWS account
- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) installed, AWS account logged in
- [Git](https://git-scm.com/), for cloning this repository

# Architecture Diagram
```mermaid
graph TD
    Player["Minecraft Player - Port 25565"] --> IGW["Internet gateway"]

    IGW --> SG

    subgraph VPC["VPC"]
        subgraph Subnets["Public subnets"]
            SG["Security group - Ingress: 25565,  Egress: all"]

            subgraph ECS["ECS cluster"]
                Task["Fargate Spot Task - Docker image taskitzg/minecraft-server:latest"]
            end

            EFSMount["EFS mount target - NFS port 2049 (Default)"]
        end
    end

    SG --> Task
    Task -->|"NFS - Port 2049"| EFSMount
    EFSMount --> EFSVol["EFS volume - vanilla world data"]
    Task -->|"logs"| CW["CloudWatch Logs (/aws/ecs/minecraft-servers)"]
    LabRole["IAM LabRole"] -->|"task execution"| Task
```

# Pipeline Diagram
```mermaid
flowchart TD
    aws["Modify ~/.aws/credentials to store relevant accses keys and session tokens from AWS"] 
    --> clone[Clone the repository] 
    --> runInit["Run `terraform init` to initialize Terraform"]
    --> spinServer["Running `terraform plan` followed by `terraform apply` spins up the Minecraft server. Terraform handles setting up the ECS, EFS, and VPC, in ecs.tf, efs.tf, and vpc.tf, respectively. "]
    
    
    spinServer --> ecs["ecs.tf: sets up an AWS Elastic Container Service (ECS) using Minecraft docker image"]
    spinServer --> efs["efs.tc: sets up AWS Elastic File System (EFS) to be used for storing server data"]
    spinServer --> vpc["vpc.tf: sets up networking through AWS Virtual Private Cloud (VPC)"]

    getIP[Run commands defined/displayed by outputs.tf to retrieve server IP]

    ecs --> getIP
    efs --> getIP
    vpc --> getIP

    getIP --> connect["Connect to the server using the server IP. (Alternatively, use nmap on the server IP to check that the server is up)"]
```
<!-- ## Written Pipeline Steps
The steps of the pipeline are as follows:
1. Modify the file `~/.aws/credentials` to store the relevant access keys and session tokens from AWS
2. Clone the repository
3. Run `terraform init` to initialize Terraform
4. Running `terraform plan` followed by `terraform apply` spins up the Minecraft server. Terraform handles setting up the ECS (Elastic Container Service), EFS (Elastic File System), and VPC (Virtual Private Cloud), in `ecs.tf`, `efs.tf`, and `vpc.tf`, respectively. 
      - `ecs.tf` sets up an AWS ECS container service using this [Minecraft Docker Image](https://github.com/itzg/docker-minecraft-server)
      - `efs.tf` sets up an AWS EFS, which the ECS instance uses to store Minecraft server data
      - `vpc.tf` sets up the AWS VPC used to faciliate networking/connections to the server
      - `locals.tf` contains configurable data, such as the CIDR to use for the VPC. 
      -  `variables.tf` contains the Minecraft username(s) to be whitelisted (allowed into the server).
5. Run the commands in Step 7 of "[Running the Minecraft Server](#running-the-minecraft-server)" to retrieve the server IP
6. Connect to the Minecraft server using the IP. 
   - Alternatively, access it with `nmap -sV -Pn -p T:<query_port> <instance_public_ip>`. This will require downloading [`nmap`](https://nmap.org/download.html) -->

# Running the Minecraft Server
1. Modify the file `~/.aws/credentials` to store the following information from AWS: 
   ```
   [default (or a name of your choice)]
   aws_access_key_id=your_aws_access_key
   aws_secret_access_key=your_aws_secret_access_key
   aws_session_token=your_aws_session_token
   ```
2. Run `git clone https://github.com/jamie-dang-n/CS_312_Course_Proj_pt2.git` to clone this repository.
3. `cd` into `CS_312_Course_Proj_pt2`. 
4. Run `terraform init` to initialize Terraform
5. Run `terraform plan` to error-check the cloned `.tf` files
   - There should be no error messages, but if there are, refer to the Terraform and AWS documentation for support [\[3\]](#references).
6. Run `terraform apply` to spin up the Minecraft server
   - If prompted, supply your Minecraft username to whitelist your connection to the server
7. Wait for about 5 minutes for the Minecraft server to start
8. Run the following commands to get the server's IP address:
    ```bash
    TASK_ARN=$(aws ecs list-tasks --cluster minecraft-servers --query 'taskArns[0]' --output text)

    ENI_ID=$(aws ecs describe-tasks --cluster minecraft-servers --tasks $TASK_ARN \
    --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text)

    aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID \
    --query 'NetworkInterfaces[0].Association.PublicIp' --output text
    ```
    - Note: The server IP will change, because the IP is not static-- the configuration does not use Elastic IP for cost saving.
    - Optionally, verify that the server is accessible with `nmap -sV -Pn -p T:<query_port> <instance_public_ip>`. This will require downloading [`nmap`](https://nmap.org/download.html)

# Connecting to the Minecraft Server
Run the commands in Step 7 of "[Running the Minecraft Server](#running-the-minecraft-server)". Then, copy the IP address to directly connect to the server in Minecraft.

Alternatively, verify that the server is accessible with `nmap -sV -Pn -p T:<query_port> <instance_public_ip>`. This will require downloading [`nmap`](https://nmap.org/download.html)

# References
\[1\] [https://www.thelastdev.com/p/learning-ecs-the-fun-way-hosting](https://www.thelastdev.com/p/learning-ecs-the-fun-way-hosting)

\[2\] [https://github.com/siakon89/minecraft-server/tree/budget-server](https://github.com/siakon89/minecraft-server/tree/budget-server)

\[3\] [https://registry.terraform.io/providers/hashicorp/aws/latest/docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

\[4\] [https://github.com/itzg/docker-minecraft-server](https://github.com/itzg/docker-minecraft-server)