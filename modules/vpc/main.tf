variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_a_cidr_block" {
  description = "CIDR block for the public subnet-a"
  type        = string
}

variable "public_subnet_b_cidr_block" {
  description = "CIDR block for the public subnet-b"
  type        = string
}

variable "private_subnet_a_cidr_block" {
  description = "CIDR block for the private subnet-a"
  type        = string
}

variable "private_subnet_b_cidr_block" {
  description = "CIDR block for the private subnet-b"
  type        = string
}

resource "aws_vpc" "nbc-lab" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.nbc-lab.id
  cidr_block              = var.public_subnet_a_cidr_block
  availability_zone       = "us-west-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.nbc-lab.id
  cidr_block              = var.public_subnet_b_cidr_block
  availability_zone       = "us-west-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.nbc-lab.id
  cidr_block              = var.private_subnet_a_cidr_block
  availability_zone       = "us-west-1a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = aws_vpc.nbc-lab.id
  cidr_block              = var.private_subnet_b_cidr_block
  availability_zone       = "us-west-1b"
  map_public_ip_on_launch = false
}

resource "aws_internet_gateway" "nbc-lab" {
  vpc_id = aws_vpc.nbc-lab.id
}

resource "aws_nat_gateway" "nbc-lab" {
  allocation_id = aws_eip.nbc-lab.id
  subnet_id     = aws_subnet.public_subnet_a.id
}

resource "aws_eip" "nbc-lab" {
  domain = "vpc"
}

resource "aws_route_table" "public_subnet" {
  vpc_id = aws_vpc.nbc-lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nbc-lab.id
  }
}

resource "aws_route_table" "private_subnet" {
  vpc_id = aws_vpc.nbc-lab.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nbc-lab.id
  }
}

resource "aws_route_table_association" "public_subnet_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_subnet.id
}

resource "aws_route_table_association" "public_subnet_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_subnet.id
}

resource "aws_route_table_association" "private_subnet_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_subnet.id
}

resource "aws_route_table_association" "private_subnet_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_subnet.id
}