

#create vpc
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = var.dns_support
  enable_dns_hostnames = var.dns_support
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0" #here you cant give list because it will be only one value always
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_security_group" "security_group" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port = var.ingress_values[0]
    to_port = var.ingress_values[2]
    protocol = var.ingress_values[1]
    # cidr_blocks = var.cidr_block[0] you cannot provide like this, because the resulting value will be a string but you need to rpovide list
    cidr_blocks = var.cidr_block
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = var.cidr_block
  }
}

# create server
resource "aws_instance" "webserver" {
  count = var.config.instance_count #optional, when you want to iterate something through values, it expects number type
  region = var.config.region
  monitoring = var.config.monitoring  #if true the launched ec2 instance will be enabled with detailed monitoring
  instance_type = "t2.micro"
  ami = "ami-0567589d25e06853e"
  # region = tolist(var.allowed_region)[0] #you cannot access set values individually as it is, you need to comnvert it to list and then access that converted list values by their index
  subnet_id = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.security_group.id]
  associate_public_ip_address = true

  tags = var.tags


}

# create s3 bucket
# resource "aws_s3_bucket" "my_bucket" {
#   bucket = "meghnathsiddesh699016543"
#   tags = {
#     Name = local.bucket_name
#     Environment = local.env 
#   } 
# }