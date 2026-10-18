resource "aws_instance" "webserver" {
  count = 1
  instance_type = "t2.micro"
  ami = "ami-0567589d25e06853e"
}