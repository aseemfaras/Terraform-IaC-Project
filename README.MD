# Terraform Infrastructure as Code (IaC) Project

## Project Overview
This Terraform project sets up an AWS infrastructure that includes:
- A **VPC** with two public subnets
- An **Internet Gateway** for internet access
- A **Route Table** with routes for internet connectivity
- A **Security Group** allowing HTTP and SSH traffic
- Two **EC2 instances** as web servers with user data scripts
- An **S3 bucket** for storage
- An **Application Load Balancer (ALB)** for distributing traffic
- A **Target Group** and **Listener** for ALB

## Prerequisites
Ensure you have the following installed before deploying this project:
1. [Terraform](https://developer.hashicorp.com/terraform/downloads)
2. [AWS CLI](https://aws.amazon.com/cli/)
3. An AWS account with necessary IAM permissions
4. A configured AWS profile (`aws configure`)

## Terraform Setup and Deployment
Follow these steps to deploy the infrastructure:

1. **Clone the Repository:**
   ```sh
   git clone https://github.com/your-username/terraform-iaac-project.git
   cd terraform-iaac-project
   ```

2. **Initialize Terraform:**
   ```sh
   terraform init
   ```

3. **Validate Configuration:**
   ```sh
   terraform validate
   ```

4. **Plan Deployment:**
   ```sh
   terraform plan
   ```

5. **Apply Changes (Deploy the Infrastructure):**
   ```sh
   terraform apply -auto-approve
   ```

6. **Retrieve Load Balancer DNS (To access the web application):**
   ```sh
   terraform output loadbalancerdns
   ```

## Destroying the Infrastructure
To remove all AWS resources created by this project:
```sh
terraform destroy -auto-approve
```
