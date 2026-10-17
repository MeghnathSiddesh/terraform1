terraform {
  backend "s3" {
    bucket = "meghnathsiddesh56825642 "
    key = "terraformlearning/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    use_lockfile = true
  }
}