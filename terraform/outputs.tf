output "cluster_name" {
  value = module.eks.cluster_name
  description = "The name of the EKS cluster"
}
output "aws_region" {
  value       = var.aws_region
  description = "The AWS region being used for the deployment"
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
  description = "The API server endpoint of the EKS cluster"
}

output "cluster_ca_certificate" {
  value = module.eks.cluster_certificate_authority_data
  description = "The base64 encoded certificate authority data for the EKS cluster"
}

# output "kubeconfig_command_example" {
#  value = "aws eks update-kubeconfig --name ${module.eks.cluster_id} --region ${var.aws_region}"
#  description = "Example command to generate kubeconfig for the EKS cluster"
#}

output "ecr_repository_url" {
  value = aws_ecr_repository.api_repo.repository_url
  description = "The URL of the ECR repository"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_outputs.id
  description = "The name of the S3 bucket where Terraform outputs are stored"
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.terraform_outputs.arn
  description = "The ARN of the S3 bucket where Terraform outputs are stored"
}
