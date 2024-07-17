provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "demo-server" {
 ami = "ami-0b72821e2f351e396"
 instance_type = "t2.micro"
 key_name = "dpp"
 security_groups = [ "allow_ssh" ]

}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "SSH access"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_vpc_security_group_egress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
