terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-2"
  
}

resource "aws_instance" "example_server" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "createdbyterraform"
  }
}


resource "aws_dynamodb_table" "dynamotable" {
  name             = var.dynamotablename
  hash_key         = var.hash_key
  billing_mode     = var.billing_mode
  stream_enabled   = true
  stream_view_type = var.stream_view_type

  attribute {
    name = var.attributename
    type = "S"
  }

  replica {
    region_name = "us-east-2"
  }

}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "main-subnet"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "allow_ssh"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }



  tags = {
    Name = "ec2-sg"
  }
}