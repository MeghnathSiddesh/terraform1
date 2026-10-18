
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
variable "instance_count" {
  type = number
  default = 1
}

variable "dns_support" {
  default = true
}

variable "cidr_block" {
  default = ["0.0.0.0/0","10.0.0.0/16","192.168.0.0/16","172.16.0.0/12"]
  type = set(string)
}

variable "allowed_region" {
  type = set(string)
  default = [ "us-east-1","us-west-1","eu-central-1","ap-northeast-1","us-east-1" ] #you cannot enter duplicate values inside set, even if you enter it will omit the duplicated value, you cant access individual value of list, you need to access it as whole
  # it is unordered, so it dont have index
}

# you cannot reference one variable inside another variable in Terraform (specifically, you cannot use a variable inside the default value of another variable).

# but you can refer variables inside locals

variable "tags" {
  type = map(string)
  default  = {
    env = "dev"
    name = "dev-server"
    numbers = "2" #terraform will take this value as string, because by default the tag is of map(string) type
}

# you can access them using var.variable_name['key_name']
}

variable "ingress_values" {
  type = tuple([ number, string, number ])
#   tuple can store multiple diff types of values, but you need to decalre thos type before ypu initialise the values
  default = [ 443, "tcp", 443 ]
#  tuples are indexed, so you can access them using variable[index]
}

variable "config" {
  type = object({
    region = string
    instance_count = number
    monitoring = bool 
  })
  default = {
    region = "us-east-1"
    instance_count = 1
    monitoring = true
  }
#   you can access them using var.variable_name.key_name
}