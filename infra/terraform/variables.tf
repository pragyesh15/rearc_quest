variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "docker_image" {
  description = "The Docker image to deploy"
  type        = string
  default     = "pragyesh15/quest-app:latest"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_1" {
  description = "CIDR block for the subnet1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_cidr_2" {
  description = "CIDR block for the subnet2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0d682f26195e9ec0f" # Amazon Linux 2 AMI
}