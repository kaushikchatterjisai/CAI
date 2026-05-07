# Replace the contents of outputs_bkp.tf with this:
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value = aws_instance.Capstone-App.public_ip # Ensure this matches your resource name
}

output "instance_id" {
  value = aws_instance.ec2.id
}
