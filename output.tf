output "aws_ami" {
  description = "aws_ami"
  value       = data.aws_ami.ubuntu.id
}


# Show Public IPs
output "publicIP" {

  value = {
    for instance in aws_instance.sm-terraform1-ec2 :
    instance.id => instance.public_ip
  }
}
