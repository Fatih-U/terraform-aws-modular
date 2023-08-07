output "dev_ip" {
  value       = aws_instance.dev_node.public_ip
  sensitive   = false
  description = "Public IP address of the development node"
  depends_on  = []
}
