## Determine which AZs are in the region and have support for instance type

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ec2_instance_type_offerings" "t3_micro" {
  filter {
    name   = "instance-type"
    values = ["t3.micro"]
  }

  filter {
    name   = "location"
    values = data.aws_availability_zones.available.names
  }

  location_type = "availability-zone"
}

locals {
  supported_azs = toset(data.aws_ec2_instance_type_offerings.t3_micro.locations)
}



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

# Random string for resource naming of buckets, IAM roles, etc.

resource "random_string" "global_suffix" {
  length  = 8
  special = false
  upper   = false
}

#####################################

 resource "aws_vpc" "main_vpc" {
   cidr_block = "10.1.1.0/24"
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
  cidr_block        = "10.1.1.0/25"
  availability_zone = element(tolist(local.supported_azs), 0)
  tags = {
     "Name" = "CodeBuid-torsten-testhost"
     }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.1.1.128/25"
  availability_zone = element(tolist(local.supported_azs), 1)
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
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ebs_default_kms_key" "current" {
}

data "aws_kms_alias" "current_arn" {
  name = data.aws_ebs_default_kms_key.current.key_arn
}

resource "aws_instance" "linux_ec2" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet.id
  # security_groups = [aws_security_group.allow_ssh.name]

  tags = {
    Name = "CodeBuild-Torsten"
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = data.aws_kms_alias.current_arn.target_key_arn
  }

  key_name = data.aws_key_pair.vmseries.key_name
}

####### EC2 For Bedrock Interaction
# IAM Role and Policy for Bedrock Access
resource "aws_iam_role" "bedrock_ec2_role" {
  name = "bedrock-ec2-role-${random_string.global_suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "bedrock_policy" {
  name        = "bedrock-access-policy-${random_string.global_suffix.result}"
  description = "Policy to access AWS Bedrock models"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "bedrock:InvokeModel",
          "bedrock:ListModels",
          "bedrock:GetFoundationModel"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.bedrock_ec2_role.name
  policy_arn = aws_iam_policy.bedrock_policy.arn
}

# Instance profile for the EC2 instance
resource "aws_iam_instance_profile" "bedrock_ec2_profile" {
  name = "bedrock-ec2-instance-profile-${random_string.global_suffix.result}"
  role = aws_iam_role.bedrock_ec2_role.name
}



# EC2 Instance
data "aws_ssm_parameter" "amzn2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


# Create an Elastic IP
resource "aws_eip" "bedrock_eip" {
  domain = "vpc"
  tags = {
    Name = "BedrockEc2EIP"
  }
}

# Associate the Elastic IP with the EC2 instance
resource "aws_eip_association" "bedrock_eip_assoc" {
  instance_id   = aws_instance.bedrock_ec2.id
  allocation_id = aws_eip.bedrock_eip.id
}

resource "aws_instance" "bedrock_ec2" {
  ami                    = data.aws_ssm_parameter.amzn2_ami.value
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.bedrock_ec2_profile.name
  key_name               = data.aws_key_pair.vmseries.key_name
  
  # Remove this line as we're using an EIP now
  # associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install python3 -y
    sudo yum install python3-pip -y
    pip3 install boto3
    sudo yum install -y aws-cli
  EOF

  subnet_id = aws_subnet.public_subnet2.id

  tags = {
    Name = "BedrockEC2Instance"
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = data.aws_kms_alias.current_arn.target_key_arn
  }
}


###### OUTPUTS
# Output the Public IP of the instance
# Output the Elastic IP for reference
output "bedrock_ec2_eip" {
  value = aws_eip.bedrock_eip.public_ip
  description = "Elastic IP address associated with the Bedrock EC2 instance"
}