locals {
    tags = {
        Terraform   = "true"
        Environment = "dev"
    }
}

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "5.1.0"

    name = "${var.cluster_name}-vpc"
    cidr = "10.0.0.0/16"

    azs = slice(data.aws_availability_zones.available.names, 0, 2)
    public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
    enable_dns_hostnames = true
    enable_nat_gateway = true

    public_subnet_tags = {
        "kubernetes.io/role/elb" = 1
    }

    private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = 1
    }
    tags = local.tags
}



data "aws_availability_zones" "available" {}

module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "~> 21.0"

    name = var.cluster_name
    kubernetes_version  = "1.33"

    endpoint_public_access_cidrs = ["0.0.0.0/0"] 
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
            ami_type = "AL2023_x86_64_STANDARD"
            min_size = 1
            max_size = 5
            desired_size = 1
            instance_types = [var.instance_type]
        }
    }
    tags = local.tags
}

resource "aws_ecr_repository" "api_repo" {
    name = var.ecr_repo_name
    force_delete = true
    image_scanning_configuration {
        scan_on_push = true
    }

    tags = local.tags
}