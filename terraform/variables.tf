variable "aws_region" {
    type    = string
    default = "us-east-1"
}

variable "cluster_name" {
    type = string
    default = "api-cluster"
}

variable "instance_type" {
    type = string
    default = "t3.medium"
}
variable "ecr_repo_name" {
    type = string
    default = "python-api-repo"
}
