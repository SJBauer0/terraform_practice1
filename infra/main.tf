// Data Blocks

# Fetch the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  most_recent = true
  owners      = ["amazon"]
}

# Fetch outputs from the bootstrap module
data "terraform_remote_state" "bootstrap" {
  backend = "local" 

  config = {
    path = "../bootstrap/terraform.tfstate"
  }
}

// Resource Blocks

# VPC and Networking Resources
resource "aws_vpc" "sjb-vpc" {
  cidr_block = var.cidr_vpc

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "sjb-vpc"
  }
}

# Internet Gateway for the VPC
resource "aws_internet_gateway" "sjb-igw" {
  vpc_id = aws_vpc.sjb-vpc.id

  tags = {
    Name = "sjb-igw"
  }
}

# Subnet for the EC2 instance
resource "aws_subnet" "sjb-subnet" {
  cidr_block = var.aws_subnet_CIDR_block
  vpc_id     = aws_vpc.sjb-vpc.id
  tags = {
    Name = "sjb-subnet"
  }
}

# Route for Internet Access
resource "aws_route" "internet-route" {
  route_table_id         = aws_route_table.sjb-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.sjb-igw.id
}

# Route Table for the Subnet
resource "aws_route_table" "sjb-rt" {
  vpc_id = aws_vpc.sjb-vpc.id
  
  tags = {
    Name = "sjb-rt"
  }
}

# Security Group for the EC2 instance
resource "aws_security_group" "sjb-sg" {
  name        = "sjb-sg"
  description = "Security group for sjb-ec2 instance"
  vpc_id      = aws_vpc.sjb-vpc.id

}

# Ingress rule for SSH access
resource "aws_vpc_security_group_ingress_rule" "sjb-sg-ingress" {
  security_group_id = aws_security_group.sjb-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

# Egress rule for outbound traffic
resource "aws_vpc_security_group_egress_rule" "sjb-sg-egress" {
  security_group_id = aws_security_group.sjb-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443

}

# Associate the subnet with the route table
resource "aws_route_table_association" "sjb-rt-association" {
  subnet_id      = aws_subnet.sjb-subnet.id
  route_table_id = aws_route_table.sjb-rt.id

}

# EC2 Instance for SJB
resource "aws_instance" "sjb-ec2" {
  ami                         = data.aws_ami.amazon_linux.id
  availability_zone           = aws_subnet.sjb-subnet.availability_zone
  instance_type               = var.ec2_instance_type
  vpc_security_group_ids      = [aws_security_group.sjb-sg.id]
  subnet_id                   = aws_subnet.sjb-subnet.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.sjb_ssm_profile.name

  # user_data = file("docker-install.txt")

  tags = {
    Name = "sjb-ec2"
  }

}

# IAM Resources
resource "aws_iam_instance_profile" "sjb_ssm_profile" {
  name = "sjb-ssm-profile-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  role = aws_iam_role.sjb_ssm_role.name
}

# IAM Role for SSM to manage SJB instances
resource "aws_iam_role" "sjb_ssm_role" {
  name = "sjb-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
          Effect = "Allow"
          Principal = {
          Service = "ec2.amazonaws.com"

        }
        Action = "sts:AssumeRole"
       }
      # The * means this role can be assumed by any service.
      # Resource = "*"
    ]
  })
}

// Output Blocks

output "resource_ids" {
  value = {
    vpc_id       = aws_vpc.sjb-vpc.id
    subnet_id    = aws_subnet.sjb-subnet.id
    igw_id       = aws_internet_gateway.sjb-igw.id
    rt_id        = aws_route_table.sjb-rt.id
    sg_id        = aws_security_group.sjb-sg.id
    aws_instance = aws_instance.sjb-ec2.id
    s3_bucket_id = data.terraform_remote_state.bootstrap.outputs.s3_bucket_name
    route_table_id = aws_route_table.sjb-rt.id
    
  }
}