// Data Blocks

data "aws_ami" "amazon_linux" {
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  most_recent = true
  owners      = ["amazon"]
}

data "terraform_remote_state" "bootstrap" {
  backend = "local" 

  config = {
    path = "../bootstrap/terraform.tfstate"
  }
}

// Resource Blocks

resource "aws_vpc" "sjb-vpc" {
  cidr_block = var.cidr_vpc

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "sjb-vpc"
  }
}

resource "aws_internet_gateway" "sjb-igw" {
  vpc_id = aws_vpc.sjb-vpc.id

  tags = {
    Name = "sjb-igw"
  }
}

resource "aws_subnet" "sjb-subnet" {
  cidr_block = var.aws_subnet_CIDR_block
  vpc_id     = aws_vpc.sjb-vpc.id
  tags = {
    Name = "sjb-subnet"
  }
}

resource "aws_route" "internet-route" {
  route_table_id         = aws_route_table.sjb-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.sjb-igw.id
}

resource "aws_route_table" "sjb-rt" {
  vpc_id = aws_vpc.sjb-vpc.id

  tags = {
    Name = "sjb-rt"
  }
}

resource "aws_security_group" "sjb-sg" {
  name        = "sjb-sg"
  description = "Security group for sjb-ec2 instance"
  vpc_id      = aws_vpc.sjb-vpc.id

}

resource "aws_vpc_security_group_ingress_rule" "sjb-sg-ingress" {
  security_group_id = aws_security_group.sjb-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "sjb-sg-egress" {
  security_group_id = aws_security_group.sjb-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443

}

resource "aws_route_table_association" "sjb-rt-association" {
  subnet_id      = aws_subnet.sjb-subnet.id
  route_table_id = aws_route_table.sjb-rt.id

}

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

resource "aws_iam_instance_profile" "sjb_ssm_profile" {
  name = "sjb-ssm-profile"
  role = aws_iam_role.sjb_ssm_role.name
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
    aws_user     = data.terraform_remote_state.bootstrap.outputs.username-mgmt.id
    route_table_id = aws_route_table.sjb-rt.id
    
  }
}