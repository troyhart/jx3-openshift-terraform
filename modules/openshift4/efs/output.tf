output "filesystem_id" {
  description = "EFS filesystem ID"
  value       = aws_efs_file_system.openshift_pv.id
}
output "efs_dns_name" {
  description = "EFS FQDN"
  value       = aws_efs_file_system.openshift_pv.dns_name
}
