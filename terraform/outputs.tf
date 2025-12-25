output "db_endpoint" {
  value = aws_db_instance.postgres.address
}
output "cluster_name" {
  value = module.eks.cluster_name
}
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
output "ecr_repo_url" {
  value = aws_ecr_repository.backend.repository_url
}
