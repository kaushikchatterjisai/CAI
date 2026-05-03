resource "aws_security_group" "sg" {
  name        = "capstone-sg"
  description = "Allow 8080 for web app"

  ingress {
    description = "Allow port 8080 from everywhere" # CKV_AWS_23 fix
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound HTTP traffic for updates" # CKV_AWS_23 fix
    from_port   = 80
    to_port     = 80
    protocol    = "tcp" # CKV_AWS_382 fix: Replaced -1 (all) with specific port
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound HTTPS traffic for updates"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2" {
  ami           = "ami-0388e3ada3d9812da"
  instance_type = "t3.medium"
  key_name      = "tf-pk"

  vpc_security_group_ids = [aws_security_group.sg.id]
  monitoring             = true           # CKV_AWS_126 fix
  ebs_optimized          = true           # CKV_AWS_135 fix
  iam_instance_profile   = "my-iam-role"  # CKV2_AWS_41 fix (Assumes role exists)

  root_block_device {
    encrypted = true # CKV_AWS_8 fix
  }

  metadata_options {
    http_tokens = "required" # CKV_AWS_79 fix (Enforces IMDSv2)
  }
 # 1. Create the IAM Role
resource "aws_iam_role" "ec2_role" {
  name = "capstone-ec2-role"
   }
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# 2. Create the Instance Profile (This is what the EC2 uses)
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "capstone-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# 3. Update your EC2 resource to use the new profile
resource "aws_instance" "ec2" {
  # ... 
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  # ...
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
