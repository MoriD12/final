variable "region" {
    default = "us-east-1"
}

variable "ami" {
    default = "ami-0e1bed4f06a3b463d"
}

variable "instance_type" {
    default = "t2.micro"
}

variable "name" {
    default = "moran"
}

variable "az" {
    default = "us-east-1a"
}

variable "vpc_cidr" {
    default = "10.0.0.0/16"
}

variable "ssh_key" {
    default = "moran_ssh_key"
}
