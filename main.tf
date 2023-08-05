

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

#Step8 - Create datasources,tf file and add ec2 AMI image to be created in this file

#Step9 - Add aws keypair for login
/*
 - Open terninal and execute command ; ssh-keygen -t ed25519
 - Enter filename with path ; /home/fatih/.ssh/fatih_key
 - two files will be created in specified path ; fatih_key and fatih_key.pub
*/

resource "aws_key_pair" "fatih_auth" {
  key_name   = "fatih_key"
  public_key = file(" ~/.ssh/fatih_key.pub")

}

#Step10 - Create EC2 instance
resource "aws_instance" "dev_node" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.fatih_auth.id
  vpc_security_group_ids = [aws_security_group.fatih_sg.id]
  subnet_id              = aws_subnet.fatih_public_subnet.id
  #add user data from userdata.tpl file. this userdata installs required software
  user_data = file("userdata_apache.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "dev-node"
  }
  /*
    In Terraform, a provisioner is a feature that allows you to execute scripts or commands on a remote resource after it has been created or destroyed. 
    Provisioners are useful for performing tasks that cannot be managed directly through Terraform configuration, 
    such as installing software, configuring applications, or setting up the environment on the remote resource.
    */
  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu"
      identityfile = "~/.ssh/fatih_key"
    })
    interpreter = var.host_os == "linux" ? ["bash", "-c"] : ["Powershell", "-Command"]
  }
  

}
