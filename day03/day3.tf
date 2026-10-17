terraform {
  required_providers {
    aws ={
        source = "hashicorp/aws"
        version = "~>6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# create s3 bucket
resource "aws_s3_bucket" "demo_bucket" {
    bucket = "meghnathsiddesh56825642"
# updating the bucket tag in 2nd run
    tags = {
      name = "Meghnathsiddesh"
      Env = "Production"
    }
# now in tf plan/apply it will check and only t eh changes will be displayed and created
}

# terraform plan (The Preview)
# What it does: It creates an execution plan by comparing your desired infrastructure code (current .tf files) with your actual cloud resources (or state file).
# terraform plan compares your code with both(state file and aws API), but primarily relies on the state file for speed, while optionally checking parts of AWS depending on the situation.
# By default (Fast Refresh): Before doing the comparison with state file, Terraform performs a quick refresh by querying the cloud provider (AWS API) to check the real-world status of the resources tracked in your state file. This ensures that if someone went into the AWS Console and manually deleted or changed a resource, Terraform knows about it.
# Skipping the refresh: If you want it to rely strictly on the local state file without querying AWS (which makes the plan run faster), you can pass the -refresh=only or -refresh=false flags, though checking AWS is the safe default.

# How it works: Terraform figures out what needs to change to match your code, but it does not make any actual changes to your cloud provider.
# What you will see:
# A + sign for resources that will be created.
# A - sign for resources that will be destroyed.
# A ~ sign for resources that will be modified/updated.
# Why use it: It acts as a safety check. You use it to review your changes and make sure Terraform isn't going to accidentally delete or break something important before you commit to it.

# terraform apply (The Execution)
# What it does: It executes the actions proposed in your execution (terraform plan)plan to build, update, or destroy infrastructure in your cloud environment.
# How it works:
# By default, running terraform apply will automatically run a fresh terraform plan behind the scenes and then prompt you for confirmation (yes/no) before proceeding.(you can run directly terraform apply due to this feature)
# Once you type yes, Terraform connects to your cloud provider's API (e.g., AWS) and applies the changes.
# After a successful run, it updates your state file (terraform.tfstate) to keep a record of what was created.
# if you want to bypass this promtp(yes/No)
# terraform apply --auto-approve

# terraform destroy
# terraform destroy command is used to clean up and delete all the infrastructure managed by your Terraform configuration file.
# first generate a plan showing you every resource that is going to be deleted (marked with a - sign) and ask for your confirmation (yes/no).
# : Once the deletion is complete, Terraform updates your state file to reflect that the resources no longer exist.
# terraform destroy --auto-approve (skip confirmation)
# Destroy a Specific Resource:you can target it using the -target flag
# terraform destroy -target=aws_s3_bucket.demo_bucket