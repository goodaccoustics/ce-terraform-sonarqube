resource "aws_instance" "ec2" {
  ami                         = "ami-053b0d53c279acc90"
  instance_type               = "t2.micro"
  count                       = 1
  associate_public_ip_address = true
  key_name                    = local.keypair
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.security_group.id]
  user_data                   = "${file("sonarqube_psql.sh")}"

  tags = {
    Name = "${local.resource_prefix}-ec2"
  }
}