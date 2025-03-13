provider "aws" {
  region = var.region
}

resource "aws_key_pair" "moran_ssh_key" {
  key_name = var.ssh_key
  public_key = file("~/.ssh/${var.ssh_key}.pub")
}

resource "aws_security_group" "moran_sg" {
  name = "${var.name}-sg"
  vpc_id = aws_vpc.vpc.id
  dynamic ingress {                 
    for_each = var.ingress_rules                    
      content {
        from_port = ingress.value
        to_port = ingress.value
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      } 
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "builder" {
  ami = var.ami  # ubuntu 22.04 in us-east-1
  instance_type = var.instance_type
  key_name = aws_key_pair.moran_ssh_key.key_name
  security_groups = [aws_security_group.moran_sg.name] ###############################

  tags = {
    Name = "builder"
  }
}




