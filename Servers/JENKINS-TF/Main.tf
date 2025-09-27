# ------------------ VPC & Networking ------------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "jenkins-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a" # Adjust if needed
  map_public_ip_on_launch = true

  tags = {
    Name = "jenkins-public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "jenkins-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "jenkins-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ------------------ Key Pair ------------------
resource "aws_key_pair" "jenkins" {
  key_name   = "JENKINS-TF"
  public_key = file("D:/DevOps/Projects/DevSecOpsProject/.backup/JENKINS-TF/Mumbai.pub")
}

# ------------------ Security Group ------------------
resource "aws_security_group" "jenkins_sg" {
  name        = "Jenkins-SG"
  description = "Allow Jenkins and related ports"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = [22, 80, 443, 8080, 9000, 3000, 9090, 9100]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

# ------------------ EC2 Instance ------------------
resource "aws_instance" "jenkins" {
  ami                    = "ami-0360c520857e3138f" # Ubuntu 22.04 in ap-south-1
  instance_type          = "t2.large"
  key_name               = aws_key_pair.jenkins.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  user_data = templatefile("./install_jenkins.sh", {})

  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = "Jenkins-sonar"
  }
}
