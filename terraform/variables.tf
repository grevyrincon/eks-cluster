
variable "aws_region" {
    type = string
    default = "us-east-1"
    description = "AWS region where all resources will be deployed"
    
}


variable "cluster_name" {
    type = string
    default = "api-cluster"
    description = "Name of the Kubernetes (EKS) cluster"
}


variable "instance_type" {
    type = string
    default = "t3.medium"
    description = "EC2 instance type for the EKS worker nodes"
}


variable "ecr_repo_name" {
    type = string
    default = "python-api-repo"
    description = "Name of the ECR repository to store Docker images"
}


variable "az_count" {
    type = number
    default = 2
    description = "Number of availability zones to use for high availability"
}


variable "public_subnets" {
    type = list(string)
    default = ["10.0.1.0/24", "10.0.2.0/24"]
    description = "List of CIDRs for public subnets"
}


variable "private_subnets" {
    type = list(string)
    default = ["10.0.101.0/24", "10.0.102.0/24"]
    description = "List of CIDRs for private subnets"
}


variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
    description = "CIDR block for the VPC"
}


variable "kubernetes_version" {
    type = string
    default = "1.33"
    description = "Kubernetes version to deploy"
}


variable "endpoint_public_access_cidrs" {
    type = list(string)
    default = ["0.0.0.0/0"]
    description = "List of CIDRs allowed to access the cluster public endpoint"
}


variable "node_ami_type" {
    type = string
    default = "AL2023_x86_64_STANDARD"
    description = "AMI type for EKS worker nodes"
}


variable "node_min_size" {
    type = number
    default = 1
    description = "Minimum number of nodes in the EKS node group"
}


variable "node_max_size" {
    type = number
    default = 5
    description = "Maximum number of nodes in the EKS node group"
}


variable "node_desired_size" {
    type = number
    default = 1
    description = "Desired number of nodes in the EKS node group"
}


variable "tags" {
    type = map(string)
    default = {
        Environment = "dev"       # Environment for the resources
        Project = "python-api" # Project name
        Terraform = "true"       # Indicates resources are managed by Terraform
    }
    description = "Tags applied to all resources created"
}

variable "s3_bucket_name" {
  type        = string
  default     = "my-terraform-outputs-bucket"
  description = "Nombre del bucket S3 donde se guardarán los outputs de Terraform"
}

variable "s3_bucket_region" {
  type        = string
  default     = "us-east-1"
  description = "Región donde se creará el bucket S3"
}

variable "s3_bucket_versioning" {
  type        = bool
  default     = true
  description = "Habilitar versionado en el bucket S3"
}

variable "environment" {
  description = "type of environment(dev, staging, prod)"
  type        = string
  default     = "dev"
}