variable "environment" {
  type = string
  default = "dev"
}

resource "aws_instance" "web" {
  ami = ""
  instance_type = var.environment == "dev" ? "t2.micro" : "t3.micro"
}

variable "list1" {
  type = list(number)
  default = [ 1,2,3,4,5 ]
}

output "outpute" {
  value = var.list1[*]
}