# 1. Security Group
resource "aws_security_group" "sg" {
  name        = "capstone-sg"
  description = "Allow 8080 for web app"

  ingress {
    description = "Allow port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow outbound HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow outbound HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. IAM Role
resource "aws_iam_role" "ec2_role" {
  name = "capstone-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# 3. IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "capstone-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# 4. EC2 Instance (ONLY ONE BLOCK)
resource "aws_instance" "ec2" {
  ami                    = "ami-0388e3ada3d9812da"
  instance_type          = "t3.medium"
  key_name               = "tf-pk"
  vpc_security_group_ids = [aws_security_group.sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  
  monitoring    = true
  ebs_optimized = true

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_tokens = "required"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install docker.io -y
              systemctl start docker
              systemctl enable docker
              docker run -d -p 8080:8080 yogada1/abc_tech:latest
              EOF

  tags = {
    Name = "Capstone-App"
  }
}
