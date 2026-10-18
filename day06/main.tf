
variable "bucket" {
  default = "MeghnathSiddesh69901@6543"
  type = string
}

variable "environment" {
  default = "prod"
  type = string
}

variable "Ec2_name" {
  default = "Web Server"
  type = string
}

locals {
  bucket_name = var.bucket
  env = var.environment
  Ec2_name = var.Ec2_name
}

#create vpc
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_vpc.my_vpc.id
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_security_group" "security_group" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create server
resource "aws_instance" "webserver" {
  count = 1 #optional, when you want to iterate something through values
  instance_type = "t2.micro"
  ami = "ami-0567589d25e06853e"
  subnet_id = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.security_group.id]
  associate_public_ip_address = true

  tags = {
    env = local.env
    name = local.Ec2_name
  }
}

# create s3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "MeghnathSiddesh69901@6543"
  tags = {
    Name = local.bucket_name
    Environment = local.env 
  } 
}