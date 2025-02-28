# outputs.tf
output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.quest_app_lb.dns_name
}

output "ec2_instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.quest_app_ec2.public_ip
}

output "docker_image_used" {
  description = "The Docker image used for deployment"
  value       = var.docker_image
}
