terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "adfs"
  region  = "us-east-1"
}

variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "ExampleAppServerInstance"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0ed9277fb7eb570c9"
  instance_type = "t2.micro"
  tags = {
    Name = var.instance_name
  }
}