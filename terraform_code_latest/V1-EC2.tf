provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "demo-server" {
 ami = "ami-0b72821e2f351e396"
 instance_type = "t2.micro"
 key_name = "dpp"

}