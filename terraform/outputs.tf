output "cluster_name" {
  value = module.eks.cluster_id
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  value = module.eks.cluster_certificate_authority_data
}

# output "kubeconfig_command_example" {
#  value = "aws eks update-kubeconfig --name ${module.eks.cluster_id} --region ${var.aws_region}"
#}

output "ecr_repository_url" {
  value = aws_ecr_repository.api_repo.repository_url
}