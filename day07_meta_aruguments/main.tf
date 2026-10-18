
# # iam policies will not have principal section, because they are attached directly to a principal, but resource based policy will have principal section
# # resource based policy will not have resource section, because they are attached directly to a resource, but iam policies will have resource section


# --------------------------------

# resource "aws_s3_bucket" "my_bucket" {
#     count=3
#   bucket = var.buckets[count.index]
#   tags = {
#     Name = var.buckets[count.index]
#   }
# }

# same resource using for each
resource "aws_s3_bucket" "my_bucket" {
#     for_each = length(var.buckets1) dont use length with sets, because it will not have index to calculate the length
    # for_each=3 #this will not work because it will accept only set or map 
    for_each = var.buckets1
  bucket = each.value

#   #or
#   for_each = var.buckets1
#   bucket = each.key
  tags = {
    Name = each.value
  }
}