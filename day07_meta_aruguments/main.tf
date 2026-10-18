# resource "aws_iam_role" "lambda_role" {
#   name = "lambda role"
#   assume_role_policy = jsonencode({
#     version = "v1"
#     statement = [{
#         Action = "sts:AssumeRole"
#         principal = {service = "lambda.awsamazon.com"}
#         Effect = "Allow"
#     }]
    
#   })
# }

# resource "aws_iam_policy" "lambda_role_policy" {
#   name = "lambda_role_policy"
#   policy = jsonencode({
#     version = "2026-08-14"
#     Action = ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"]
#     Effect = "Allow"
#     Resource = "arn:aws:logs:*:*:*"
#   })
# }
# # iam policies will not have principal section, because they are attached directly to a principal, but resource based policy will have principal section
# # resource based policy will not have resource section, because they are attached directly to a resource, but iam policies will have resource section

# resource "aws_iam_role_policy_attachment" "attachment" {
#   role = aws_iam_role.lambda_role.name
#   policy_arn = aws_iam_policy.lambda_role_policy.id
# }

# resource "aws_lambda_function" "my_function" {
#   function_name = "my_test_function"
#   role          = aws_iam_role.lambda_role.arn
#   handler       = "index.handler"
#   runtime       = "python3.9"
#   filename      = "lambda_function_payload.zip"

#   # Ensures IAM policy is fully bound and propagated before deploying the function
#   depends_on = [ 
#     aws_iam_role_policy_attachment.attachment
#    ]
# }


# --------------------------------

variable "server_configs" {
  type = map(object({
    ami_id = string
    instance_type = string
  }))
  default = {
    web = {
        ami_id = "ami-0567589d25e06723e"
        instance_type = "t2.micro"
    }
    # here web is key and value is {ami_id = "ami-0567589d25e08474j3" instance_type = "t3.micro"} so it is of map type
    #  {ami_id = "ami-0567589d25e08474j3" instance_type = "t3.micro"} is of object type
    app = {
        ami_id = "ami-0567589d25e08474j3"
        instance_type = "t3.micro"
    }
    db = {
        ami_id = "ami-0567589d25e0872876hj"
        instance_type = "t3.nano"
    }
  }
}

resource "aws_instance" "3_tier_servers" {
  for_each = var.server_configs
  instance_type = each.value.instance_type #accessing object values by its keys
  ami = each.value.ami_id #accessing object values by its keys
  
  tags = {
    Name = "${each.key}-server"
  }
}