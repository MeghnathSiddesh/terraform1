# variable "env" {
#   type = string
#   default = "dev"
# }
# variable "channel_name" {
#   default = "meghnathsiddesh69901"
#   # s3 bucket should not have capital letters
#   type = string
# }
# variable "region" {
#   default = "us-east-1"
#   type = string
#   # region = var.region inside aws_s3_bucket, aws_vpc, and aws_instance. Terraform resources do not take a region argument inside their blocks; the region is handled globally by your provider "aws" block.
# }

# locals {
#   Environment = var.env
#   Bucket_name = "${var.channel_name}-${var.env}"
#   vpc_name = "${var.env}-VPC"
# }

# resource "aws_s3_bucket" "first_bucket" {
#   bucket = local.Bucket_name
#   # region = var.region
#   tags = {
#     Name = local.Bucket_name
#     Environment = var.env
#   }
# }

# # create VPC
# resource "aws_vpc" "sample_vpc" {
#   cidr_block = "10.0.0.0/16"
#   enable_dns_support = true #this enables or disables the DNS resolver inside your VPC.
#   enable_dns_hostnames = true 
#   #This controls whether instances launched in your VPC receive public DNS hostnames corresponding to their public IP addresses. Every single EC2 instance you launch in an AWS VPC automatically receives a private DNS hostname
#   # region = var.region
#   # by default when we create vpc, it will create main route table which will make bridge between (internet gateway and all your subnets(if make that route)) and it will by default enable communications between subnets once the subnets keep on adding
#   tags = {
#     Name = local.vpc_name
#     Environment = local.Environment
#   }
# }
# #create subnet
# resource "aws_subnet" "public" {
#   vpc_id = aws_vpc.sample_vpc.id #we need to give under which vpc the subnet needs to be created
#   cidr_block = "10.0.0.0/24"
#   tags = {
#     name = "Dev public subnet"
#   }
# }
# #create internet gateway
# resource "aws_internet_gateway" "internet_gateway" {
#   vpc_id = aws_vpc.sample_vpc.id
# }

# #create routetable
# resource "aws_route_table" "public-route_table" {
#   vpc_id = aws_vpc.sample_vpc.id
#   # here first argument will be the destination ip/destination CIDR block
#   # second argument will be to reach that destination, where to send; the next hop
#   route {
#     #inline blocks like route,ingress,egress should not use an equals sign.ex: route = {}
#     # route1
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.internet_gateway.id
#     # Route 2: VPC Peering Connection
#   # route {
#   #   cidr_block                = "10.100.0.0/16"
#   #   vpc_peering_connection_id = "pcx-0123456789abcdef0"
#   # }

#   # Route 3: NAT Gateway
#   # route {
#   #   cidr_block     = "172.16.0.0/12"
#   #   nat_gateway_id = aws_nat_gateway.nat.id
#   # }
#   }
# }

# # Associate route table with subnet
# resource "aws_route_table_association" "public_association" {
#   subnet_id = aws_subnet.public.id
#   route_table_id = aws_route_table.public-route_table.id
# }

# # create security group
# resource "aws_security_group" "my_security_group" {
#   vpc_id = aws_vpc.sample_vpc.id
#   ingress {
#     #why we need fro_port, to_port both?
#     #this will enable us to define a range of ports like from 8000 to 8050 etc
#     # even if you want single port to enable should define both from and to port with same value
#     description = "Allow 22 from internet"
#     from_port = 22
#     to_port = 22
#     protocol ="tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   egress {
#     description = "allow all out bound traffic"
#     from_port = 0 #0 means all ports
#     to_port = 0 #0 means all ports
#     protocol = "-1" #-1 means all protocols are enabled
#     cidr_blocks = ["0.0.0.0/0"]
#     # you need to provide this value inside list because Terraform's schema for cidr_blocks is explicitly defined as a list of strings (list(string)).you can allow multiple networks in your ingress or egress blocks
#   #   cidr_blocks = [
#   #   "10.0.1.0/24",    # Subnet A
#   #   "192.168.5.0/24", # Office Network
#   #   "0.0.0.0/0"       # Entire Internet
#   # ]
#   }
# }


# resource "aws_instance" "web" {
#   # region = var.region
#   instance_type = "t2.micro"
#   ami = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"    
#   subnet_id = aws_subnet.public.id
#   vpc_security_group_ids = [aws_security_group.my_security_group.id] 
#   #You need to put it inside a list ([...]) because an AWS EC2 instance can be attached to multiple security groups at the same time.
#   # example:vpc_security_group_ids = [
# #   aws_security_group.web_sg.id,]
#   associate_public_ip_address = true

#   tags = {
#     Name = "My Server-DEV"
#     Environment = var.env
#   }
#   depends_on = [
#     aws_route_table_association.public_association
#   ]
# }

# # In Terraform, depends_on is used to create an explicit dependency between resources.

# # Normally, Terraform is smart enough to figure out dependencies automatically (implicit dependencies) when you reference one resource inside another—like using aws_subnet.public.id, which tells Terraform, "Build the subnet before you build the instance."

# # However, there are times when there is no direct reference, but you still need one resource to wait for another to finish building completely. That is when you use depends_on.
# # "Even though the EC2 instance only strictly needs the subnet ID to be created, do not start creating this EC2 instance until the Route Table Association has been fully created and attached to the subnet first."

# # Why is this useful here? (The Real-World Reason)
# # Without depends_on, Terraform might try to create the EC2 instance and the Route Table Association at the exact same time.

# # If the EC2 instance finishes launching a split second before the route table is successfully linked to the subnet, your server might boot up without a valid path to the internet. If your server tries to run startup scripts (like downloading software updates or packages via apt or yum), those commands will fail because the internet route wasn't ready yet.

# # depends_on ensures everything is wired up in the correct operational order!