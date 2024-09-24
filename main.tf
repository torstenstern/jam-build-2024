resource "aws_vpc" "vpc" {
  cidr_block = "10.2.0.0/16"
  tags = {
    "Name" = "CodeBuid-torsten"
  }
}

data "aws_key_pair" "vmseries" {
  include_public_key = true

  filter {
    name   = "key-name"
    values = ["AWSLabsKeyPair*"]
  }
}

#####################################

 resource "aws_vpc" "main_vpc" {
   cidr_block = "10.1.0.0/24"
   tags = {
     "Name" = "CodeBuid-torsten-testhost"
     }
 }

# Create an Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
     "Name" = "CodeBuid-torsten-testhost"
     }
}

# Create a Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.1.0.0/25"
  # availability_zone = var.region
  # map_public_ip_on_launch = true
  tags = {
     "Name" = "CodeBuid-torsten-testhost"
     }
}

# Create a Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
     "Name" = "CodeBuid-torsten-testhost"
     }
}

# Create a Route for Internet Traffic
resource "aws_route" "internet_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_igw.id
}

# Associate Route Table with the Public Subnet
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Create a Security Group to allow SSH and ICMP (ping)
resource "aws_security_group" "allow_ssh" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
     "Name" = "CodeBuid-torsten-testhost"
     }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 Instance
resource "aws_instance" "linux_ec2" {
  ami           = "ami-08d8ac128e0a1b91c" # Amazon Linux 2 AMI (Check your region for AMI ID)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  # security_groups = [aws_security_group.allow_ssh.name]

  tags = {
    Name = "CodeBuild-Torsten"
  }

  key_name = data.aws_key_pair.vmseries.key_name  # Replace with your SSH key pair name
}





# Output the Public IP of the instance
output "ec2_public_ip" {
  value = aws_instance.linux_ec2.public_ip
}
