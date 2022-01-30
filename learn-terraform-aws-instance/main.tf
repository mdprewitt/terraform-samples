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
  default     = "MarcTerraformTesting"
}

resource "aws_vpc" "marc-ssh-test" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags {
    name = "marc-tf-test"
  }
}

resource "aws_subnet" "marc-tf-test" {
  cidr_block = "${cidrsubnet(awc_vpc.marc-ssh-test.cidr_block, 3, 1)}"
  vpc_id     = aws_vpc.marc-ssh-test.id
  availability_zone = "us-east-1a"
}

resource "aws_security_group" "marc-test-ssh" {
  name = "marc-ssh-allow-sg"
  vpc_id = aws_vpc.marc-ssh-test.id
  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    cidr_blocks = ["98.113.29.206/32"]
  }
  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami           = "ami-0ed9277fb7eb570c9"
  instance_type = "t2.micro"
  key_name = "marc-test"
  subnet_id = "${aws_security_group.marc-test-ssh.id}"
  provisioner "local-exec" {
    command = "echo ip=${self.private_ip}"
  }
  connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = file("marc-test.pem")
  }
  provisioner "file" {
    content = "foobar"
    destination = "/tmp/foobar.txt"
  }
  tags = {
    Name = var.instance_name
  }
}