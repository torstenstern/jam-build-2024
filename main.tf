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
  tags = {
     "Name" = "CodeBuid-torsten-testhost"
     }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.1.1.128/25"
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

resource "aws_instance" "bedrock_ec2" {
  ami                    = data.aws_ssm_parameter.amzn2_ami.value #"ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI (Change based on your region)
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.bedrock_ec2_profile.name
  key_name               = data.aws_key_pair.vmseries.key_name
  associate_public_ip_address = true # To SSH into the instance

  # User data to install AWS CLI, Python, and boto3
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install python3 -y
    sudo yum install python3-pip -y
    pip3 install boto3
    sudo yum install -y aws-cli
  EOF

  subnet_id              = aws_subnet.public_subnet2.id
  #security_groups        = [aws_security_group.allow_ssh.name]

  tags = {
    Name = "BedrockEC2Instance"
  }
}


###### OUTPUTS
# Output the Public IP of the instance
output "ec2_public_ip" {
  value = aws_instance.linux_ec2.public_ip
}
