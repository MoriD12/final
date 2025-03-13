provider "aws" {
  region = var.region
}

resource "aws_key_pair" "moran_ssh_key" {
  key_name = var.ssh_key
  public_key = file("~/.ssh/${var.ssh_key}.pub")
}

resource "aws_vpc" "moran_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
}

resource "aws_internet_gateway" "moran_internet_gateway" {
    vpc_id = aws_vpc.moran_vpc.id

    tags = {
      Name = "${var.name}-IG"
    }
}

resource "aws_subnet" "moran_subnet" {
  vpc_id = aws_vpc.moran_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.az
  map_public_ip_on_launch = true
}

resource "aws_route_table" "moran_route_table" {
    vpc_id = aws_vpc.moran_vpc.id

    #connenting the route to internet_geteway- for the public subnet
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.moran_internet_gateway.id
    }
    tags = {
      Name = "${var.name}-routetable_public"
    }
}

#assosiate route table with the public subnet 
resource "aws_route_table_association" "moran_route_ass" {
    route_table_id = aws_route_table.moran_route_table.id
    subnet_id = aws_subnet.moran_subnet.id

    depends_on = [aws_subnet.moran_subnet]
}


resource "aws_security_group" "moran_sg" {
  name = "${var.name}-sg"
  vpc_id = aws_vpc.moran_vpc.id
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # Allow SSH 
    }

    ingress {
        from_port   = 5001
        to_port     = 5001
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# create ec2 machine
resource "aws_instance" "builder" {
  ami = var.ami     # ubuntu 22.04 in us-east-1
  instance_type = var.instance_type
  key_name = aws_key_pair.moran_ssh_key.key_name
  subnet_id = aws_subnet.moran_subnet.id
  vpc_security_group_ids = [aws_security_group.moran_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Add Docker's official GPG key:
              sudo apt-get update
              sudo apt-get install ca-certificates curl
              sudo install -m 0755 -d /etc/apt/keyrings
              sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
              sudo chmod a+r /etc/apt/keyrings/docker.asc
              echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
              $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
              sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
              sudo apt-get update
              sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
              
              # Install Docker Compose
              sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose
              EOF
  )

  tags = {
    Name = "builder"
  }
}




