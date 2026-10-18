
# #create vpc
# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"
#   enable_dns_hostnames = true
#   enable_dns_support = true

#   tags = {
#     Name = "alb-dem-vpc"
#   }
# }

# # create internet gateway
# resource "aws_internet_gateway" "main" {
#   vpc_id = aws_vpc.main.id
#   tags = {
#     Name = "alb-demo-igw"
#   }
# }

# # 3. Two public subnets in different AZs
# data "aws_availability_zones" "available" {
#   state = "available"
# }

# resource "aws_subnet" "public" {
#   count = 2
#   vpc_id = aws_vpc.main.id
#   cidr_block = ["10.0.1.0/24","10.0.2.0/24"][count.index]
#   availability_zone = data.aws_availability_zones.available.names[count.index]
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "alb-demo-public-${count.index+1}"
#   }
# }

# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.main.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.main.id
#   }
#   tags = {
#     Name = "alb-demo-public-rt"
#   }
# }
# # route table is to be created seperately and associate route table with both the public subnets seperately
# resource "aws_route_table_association" "public" {
#   count = 2
#   route_table_id = aws_route_table.public.id
#   subnet_id = aws_subnet.public[count.index].id
# }

# # create ALB security group seperately
# resource "aws_security_group" "alb_security_group" {
#   vpc_id = aws_vpc.main.id
#   ingress {
#     from_port = 80
#     to_port = 80
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]  #allow from all
#   }
#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = -1
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "alb-demo-sg"
#   }
# }

# # create EC2 security group seperately
# resource "aws_security_group" "EC2_server-sg" {
#   vpc_id = aws_vpc.main.id
#   ingress {
#     from_port = 8080
#     to_port = 8080
#     protocol = "tcp"
#     security_groups = [aws_security_group.alb_security_group.id] #allow from alb security groups instead of from a ip/cidr
#   }
#   ingress {
#     from_port = 8081
#     to_port = 8081
#     protocol = "tcp"
#     security_groups = [aws_security_group.alb_security_group.id]
#   }

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = -1
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "alb-demo-server-sg"
#   }
# }

# resource "aws_instance" "app" {
#   ami = "ami-0567589d25e06853e"
#   instance_type = "t2.micro"
#   subnet_id = aws_subnet.public[0].id
#   vpc_security_group_ids = [aws_security_group.EC2_server-sg.id] #associate security group
#   associate_public_ip_address = true
#   user_data = <<-EOF
#     #!/bin/bash
#     dnf install -y python3

#     mkdir -p /opt/alb-demo

#     cat > /opt/alb-demo/app1.py <<'PY'
#     from http.server import BaseHTTPRequestHandler, HTTPServer

#     class Handler(BaseHTTPRequestHandler):
#         def do_GET(self):
#             if self.path == "/health":
#                 body = b"healthy"
#             else:
#                 body = b"Hello from Application 1 on port 8080"
#             self.send_response(200)
#             self.end_headers()
#             self.wfile.write(body)

#     HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
#     PY

#     cat > /opt/alb-demo/app2.py <<'PY'
#     from http.server import BaseHTTPRequestHandler, HTTPServer

#     class Handler(BaseHTTPRequestHandler):
#         def do_GET(self):
#             if self.path == "/health":
#                 body = b"healthy"
#             else:
#                 body = b"Hello from Application 2 on port 8081"
#             self.send_response(200)
#             self.end_headers()
#             self.wfile.write(body)

#     HTTPServer(("0.0.0.0", 8081), Handler).serve_forever()
#     PY

#     nohup python3 /opt/alb-demo/app1.py \
#       > /var/log/alb-app1.log 2>&1 &

#     nohup python3 /opt/alb-demo/app2.py \
#       > /var/log/alb-app2.log 2>&1 &
#   EOF

#   tags = {
#     Name = "alb-demo-app-server"
#   }
# }

# # 8. Target Group 1 - port 8080

# resource "aws_lb_target_group" "app1" {
#   vpc_id = aws_vpc.main.id
#   protocol = "HTTP"
#   target_type = "instance"
#   port = 8080

#   health_check {
#     enabled = true
#     protocol = "HTTP"
#     port = "traffic-port"
#     path = "/health"
#     matcher = "200"
#     interval = 15
#     timeout = 5
#     healthy_threshold = 2
#     unhealthy_threshold = 3
#   }
#   tags = {
#     Name = "alb-demo-tg-8080"
#   }
# }

# # 9. Target Group 1 - port 8080
# resource "aws_lb_target_group" "app2" {
#   vpc_id = aws_vpc.main.id
#   protocol = "HTTP"
#   port = 8081
#   target_type = "instance"
#   health_check {
#     enabled = true
#     port = "traffic-port"
#     protocol = "HTTP"
#     path = "/health"
#     matcher = "200"
#     interval = 15
#     timeout = 5
#     healthy_threshold = 2
#     unhealthy_threshold = 3
#   }
#   tags = {
#     Name = "alb-demo-tg-8081"
#   }
# }

# # registering same EC2 in both the target groups
# # we can create target groups independently and need to attach the targets seperately either manual way or terraform
# resource "aws_lb_target_group_attachment" "app1" {
#   target_group_arn = aws_lb_target_group.app1.arn
#   target_id = aws_instance.app.id
#   port = 8080
# }

# resource "aws_lb_target_group_attachment" "app2" {
#   target_group_arn = aws_lb_target_group.app2.arn
#   target_id = aws_instance.app.id
#   port = 8081
# }


# # 11. Application Load Balancer
# resource "aws_alb" "main" {
#   internal = false
#   load_balancer_type = "application"
#   security_groups = [aws_security_group.alb_security_group.id]
#   subnets = aws_subnet.public[*].id

#   tags = {
#     Name = "alb-demo"
#   }
# }

# # 12. Listener on port 80

# resource "aws_alb_listener" "http" {
#   load_balancer_arn = aws_alb.main.arn
#   port = 80
#   protocol = "HTTP"
#   # by default it will forward to app1
#   default_action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.app1.arn
#   }
# }

# # 13. Route /app1/* to port 8080
# resource "aws_lb_listener_rule" "app1" {
#   listener_arn = aws_alb_listener.http.arn
#   priority = 100
#   action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.app1.arn
#   }
#   condition {
#     path_pattern {
#       values = ["/app1/","/app1/*"]
#     }
#   }
# }

# # 14. Route /app2/* to port 8081
# resource "aws_alb_listener_rule" "app2" {
#   listener_arn = aws_alb_listener.http.arn
#   priority = 200
#   action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.app2.arn
#   }
#   condition {
#     path_pattern {
#       values = ["/app2/","/app2/*"]
#     }
#   }
# }


# output "alb_dns_name" {
#   value = aws_alb.main.dns_name
# }


# output "app1_url" {
#   value = "http://${aws_alb.main.dns_name}/app1/"
# }

# output "app2_url" {
#   value = "http://${aws_alb.main.dns_name}/app2/"
# }

# output "instance_id" {
#   value = aws_instance.app.id
# }
