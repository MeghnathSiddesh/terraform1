terraform {
  backend "s3" {
    bucket = "meghnathsiddesh56825642"
    key = "terraformlearning/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    use_lockfile = true

  }
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>6.0"
    }
  }
}

resource "aws_s3_bucket" "bucket12" {
    bucket = "meghnathsiddesh5682564243"
  
}
