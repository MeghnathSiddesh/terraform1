# version = "~> 6.3.2" (pessimistic constraint operator) means: Allow updates to the last specified digit, but do not allow breaking major version updates.
# With ~> 6.3.2, Git or Terraform will match any version that is:
# Minimum: 6.3.2
# Maximum: Up to (but NOT including) 6.4.0

terraform {
  required_providers {
    aws = {
    source = "hashicorp/aws"
    version = "~> 6.0"
    }
  }
}
#  required_providers block tells Terraform which provider plugins your code needs, the registry source(hashicorp/aws), and what version to use.

provider "aws" {
  region = "us-east-1"
}
# provider block tells Terraform how to configure and connect to that provider when it runs(connection settings). This is where you pass parameters specific to your environment
# such as Credentials, profile names, or assume-role configurations, default region

resource "aws_vpc" "example" {
    cidr_block = "10.0.0.0/16"
# here example is not a vpc name, it is local name of the resource with which we refer this vpc internally in terraform code
}

# resource "aws_ec2_host" "server1" {
#     vpc_id = aws_vpc.example
# }
