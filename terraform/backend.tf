terraform {
  backend "s3" {
    bucket         = "realworld-terraform-states"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

