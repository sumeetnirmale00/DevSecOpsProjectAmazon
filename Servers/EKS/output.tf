output "name" {
    value = local.name
}

output "cluster_region" {
    value = local.region
}

output "kubeconfig_command" {
  value = "aws eks --region ${local.region} update-kubeconfig --name ${local.name}"
  description = "Command to configure kubectl for the EKS cluster"
}