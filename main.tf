# define the terraform version
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# define the cloud provider
provider "aws" {
  region = "us-east-1"
}

# define the VPC resource
resource "aws_vpc" "vpc" {
  cidr_block = "172.2.0.0/16"
  tags = {
    Name = "${local.resource_prefix}-vpc"
  }
}

# define the subnet resource
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "172.2.0.0/24"
  tags = {
    Name = "${local.resource_prefix}-public-subnet"
  }
}

# define the internet gateway resource
resource "aws_internet_gateway" "internet_getway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${local.resource_prefix}-internet-gateway"
  }
}

# define the route table resource
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_getway.id
  }

  tags = {
    Name = "${local.resource_prefix}-route-table"
  }
}

# define the route table association resource
resource "aws_route_table_association" "route_table_association" {
  count          = 1
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "security_group" {
  name        = "${local.resource_prefix}-security-group"
  description = "Allow SSH, HTTP, HTTPS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH into VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP into VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS into VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${local.resource_prefix}-security-group"
  }
}


