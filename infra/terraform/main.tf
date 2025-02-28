provider "aws" {
  region = var.region
}

# Generate a private key
resource "tls_private_key" "quest_app_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create an AWS key pair
resource "aws_key_pair" "quest_app_key_pair" {
  key_name   = "quest-app-key" # Name of the key pair in AWS
  public_key = tls_private_key.quest_app_key.public_key_openssh
}

# Save the private key to a file
resource "local_file" "quest_app_private_key" {
  content  = tls_private_key.quest_app_key.private_key_pem
  filename = "quest-app-key.pem"
  file_permission = "0400" # Restrict permissions to read-only for the owner
}

# Create a VPC
resource "aws_vpc" "quest_app_vpc" {
  cidr_block = var.vpc_cidr
}

# Create a Subnet
resource "aws_subnet" "quest_app_subnet_1" {
  vpc_id            = aws_vpc.quest_app_vpc.id
  cidr_block        = var.subnet_cidr_1
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true # Automatically assign public IPs
}

resource "aws_subnet" "quest_app_subnet_2" {
  vpc_id            = aws_vpc.quest_app_vpc.id
  cidr_block        = var.subnet_cidr_2
  availability_zone = "${var.region}b"
}

# Create an Internet Gateway
resource "aws_internet_gateway" "quest_app_igw" {
  vpc_id = aws_vpc.quest_app_vpc.id

  tags = {
    Name = "quest-app-igw"
  }
}

# Create a Route Table
resource "aws_route_table" "quest_app_route_table" {
  vpc_id = aws_vpc.quest_app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.quest_app_igw.id
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "quest_app_route_table_assoc_1" {
  subnet_id      = aws_subnet.quest_app_subnet_1.id
  route_table_id = aws_route_table.quest_app_route_table.id
}

resource "aws_route_table_association" "quest_app_route_table_assoc_2" {
  subnet_id      = aws_subnet.quest_app_subnet_2.id
  route_table_id = aws_route_table.quest_app_route_table.id
}

# Create a Security Group
resource "aws_security_group" "quest_app_sg" {
  vpc_id = aws_vpc.quest_app_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.quest_app_lb_sg.id] # Allow traffic only from the load balancer
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 Instance
resource "aws_instance" "quest_app_ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.quest_app_subnet_1.id
  key_name      = aws_key_pair.quest_app_key_pair.key_name # Use the key pair
  vpc_security_group_ids = [aws_security_group.quest_app_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              service docker start
              usermod -a -G docker ec2-user
              docker pull ${var.docker_image}
              docker run -d -p 80:80 ${var.docker_image}
              sleep 30
              EOF

  tags = {
    Name = "NodeJS-App-EC2"
  }
}

# Security Group for Load Balancer
resource "aws_security_group" "quest_app_lb_sg" {
  vpc_id = aws_vpc.quest_app_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a Load Balancer
resource "aws_lb" "quest_app_lb" {
  name               = "quest-app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.quest_app_lb_sg.id]
  subnets            = [aws_subnet.quest_app_subnet_1.id, aws_subnet.quest_app_subnet_2.id]

  enable_deletion_protection = false
}

# Create a Target Group
resource "aws_lb_target_group" "quest_app_tg" {
  name     = "quest-app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.quest_app_vpc.id

  health_check {
    path                = "/"               # Health check path (root path by default)
    interval            = 30                # Health check interval (seconds)
    timeout             = 5                 # Health check timeout (seconds)
    healthy_threshold   = 3                 # Number of successful checks to mark as healthy
    unhealthy_threshold = 3                 # Number of failed checks to mark as unhealthy
    matcher             = "200"             # HTTP status code to consider healthy
  }
}

# Attach EC2 Instance to Target Group
resource "aws_lb_target_group_attachment" "quest_app_tg_attachment" {
  target_group_arn = aws_lb_target_group.quest_app_tg.arn
  target_id        = aws_instance.quest_app_ec2.id
  port             = 80
}

# Create a Listener
resource "aws_lb_listener" "quest_app_listener" {
  load_balancer_arn = aws_lb.quest_app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.quest_app_tg.arn
  }
}