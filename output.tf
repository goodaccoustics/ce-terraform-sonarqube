output "ec2-public-ip" {
  value = aws_instance.ec2.public_ip
}

output "ec2-ssh" {
  value = "ssh -i ${local.keypair}.pem ubuntu@${aws_instance.ec2.public_ip}"
}