#Step1 - Create a VPC
resource "aws_vpc" "fatih-vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev-vpc"
  }
}
#Step2 - Create a subnet associated with VPC created in step1
resource "aws_subnet" "fatih_public_subnet" {
  vpc_id                  = aws_vpc.fatih-vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "dev-public-subnet"
  }
}
#Step3 - Create an internet gateway for public access to VPC
resource "aws_internet_gateway" "fatih_internet_gateway" {
  vpc_id = aws_vpc.fatih-vpc.id

  tags = {
    Name = "dev-igw"
  }

}

#Step4 - Create route table
resource "aws_route_table" "fatih_public_route_table" {
  vpc_id = aws_vpc.fatih-vpc.id


  tags = {
    Name = "dev-public-rt"
  }
}

#Step5 - Create route entries for route table
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.fatih_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.fatih_internet_gateway.id

}

#Step6 - Create route table associations - associate route table with subnet
resource "aws_route_table_association" "fatih_public_association" {
  subnet_id      = aws_subnet.fatih_public_subnet.id
  route_table_id = aws_route_table.fatih_public_route_table.id
}


#Step7 - Create security group and add SG rules
resource "aws_security_group" "fatih_sg" {
  name        = "dev_sg"
  description = "dev_security_group"
  vpc_id      = aws_vpc.fatih-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

}
