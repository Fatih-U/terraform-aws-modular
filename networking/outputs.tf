output "security_group_id" {
  value       = aws_security_group.fatih_sg.id
  sensitive   = true
  description = "Security group id"
}

output "subnet_id" {
  value       = aws_subnet.fatih_public_subnet.id
  sensitive   = true
  description = "Subnet id"
}
