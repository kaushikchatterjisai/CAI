provider "aws" {
  region = "ap-south-1"
}

resource "aws_security_group" "sg" {
  name        = "capstone-sg"
  description = "Allow 8080 for web app"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Adding egress so the instance can download Docker packages
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2" {
  ami           = "ami-0388e3ada3d9812da" # Ensure this is a valid Ubuntu AMI for ap-south-1
  instance_type = "t3.medium"
  key_name      = "tf-pk"

  # Use vpc_security_group_ids for standard VPC deployments
  vpc_security_group_ids = [aws_security_group.sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install docker.io -y
              systemctl start docker
              systemctl enable docker
              
              # Note: $BUILD_NUMBER is a Jenkins variable. 
              # If running via Jenkins, ensure this is interpolated correctly or hardcoded for testing.
              docker run -d -p 8080:8080 yogada1/abc_tech:latest
              EOF

  tags = {
    Name = "Capstone-App"
  }
}

output "public_ip" {
  value = aws_instance.ec2.public_ip
}
