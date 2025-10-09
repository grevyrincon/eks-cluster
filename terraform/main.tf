
data "aws_availability_zones" "available" {}

# -------------------
# VPC
# -------------------
module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "5.1.0"

    name = "${var.cluster_name}-vpc"
    cidr = var.vpc_cidr

    azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
    public_subnets = var.public_subnets
    private_subnets = var.private_subnets
    enable_dns_hostnames = true
    enable_nat_gateway = true

    public_subnet_tags = {
        "kubernetes.io/role/elb" = 1
    }

    private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = 1
    }
    tags = var.tags
}

# -------------------
# EKS Cluster
# -------------------
module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "~> 21.0"

    name = var.cluster_name
    kubernetes_version  = var.kubernetes_version

    endpoint_public_access_cidrs = var.endpoint_public_access_cidrs
    endpoint_public_access = true

    addons = {
        coredns = {}
        eks-pod-identity-agent = {
            before_compute = true
        }
        kube-proxy = {}
        vpc-cni = {
            before_compute = true
        }
    }

    subnet_ids = module.vpc.private_subnets
    vpc_id = module.vpc.vpc_id
    
    eks_managed_node_groups = {
        api-node = {
            ami_type = var.node_ami_type
            min_size = var.node_min_size
            max_size = var.node_max_size
            desired_size = var.node_desired_size
            instance_types = [var.instance_type]
        }
    }
    tags = var.tags
}

resource "aws_ecr_repository" "api_repo" {
    name = var.ecr_repo_name
    force_delete = true
    image_scanning_configuration {
        scan_on_push = true
    }

    tags = var.tags
}

# -------------------
# S3 Bucket para Terraform outputs
# -------------------
resource "aws_s3_bucket" "terraform_outputs" {
  bucket = var.s3_bucket_name
  region = var.s3_bucket_region

  tags = merge(
    var.tags,
    {
      Name        = var.s3_bucket_name
      Environment = "shared"
    }
  )
}

# Habilitar versionado si está activado
resource "aws_s3_bucket_versioning" "terraform_outputs_versioning" {
  bucket = aws_s3_bucket.terraform_outputs.id

  versioning_configuration {
    status = var.s3_bucket_versioning ? "Enabled" : "Suspended"
  }
}

resource "null_resource" "export_outputs_to_s3" {
  triggers = {
    environment = var.environment
  }
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = "terraform output -json > outputs.json && aws s3 cp outputs.json s3://${var.s3_bucket_name}/outputs/${var.environment}-outputs.json"
  }

  depends_on = [
    module.eks,
    aws_ecr_repository.api_repo,
    aws_s3_bucket.terraform_outputs
  ]
}

