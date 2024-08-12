provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "demo-server" {
 ami = "ami-04a81a99f5ec58529"
 instance_type = "t2.micro"
 key_name = "dpp"
 //security_groups = [ "allow_ssh" ]

 vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]
 subnet_id = aws_subnet.dpp-public-subnet-01.id
for_each = toset(["jenkins-master", "build-slave","ansible"])
 tags = {
    Name = "${each.key}"
  }

}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "SSH access"
  vpc_id = aws_vpc.dpp-vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_jenkins_port" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}


resource "aws_vpc_security_group_egress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc" "dpp-vpc"{
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "dpp-vpc"
  }
}

resource "aws_subnet" "dpp-public-subnet-01"{
  vpc_id = aws_vpc.dpp-vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
  tags = {
    Name = "dpp-public-subnet-01"
  }
}

resource "aws_subnet" "dpp-public-subnet-02"{
  vpc_id = aws_vpc.dpp-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1b"
  tags = {
    Name = "dpp-public-subnet-02"
  }
}

resource "aws_internet_gateway" "dpp-igw"{
  vpc_id = aws_vpc.dpp-vpc.id
  tags = {
    Name = "dpp-igw"
  }
}

resource "aws_route_table" "dpp-public-rt"{
  vpc_id = aws_vpc.dpp-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dpp-igw.id
  }
}

resource "aws_route_table_association" "dpp-rta-public-subnet-01" {
 subnet_id = aws_subnet.dpp-public-subnet-01.id
 route_table_id = aws_route_table.dpp-public-rt.id

}

resource "aws_route_table_association" "dpp-rta-public-subnet-02" {
 subnet_id = aws_subnet.dpp-public-subnet-02.id
 route_table_id = aws_route_table.dpp-public-rt.id

}



