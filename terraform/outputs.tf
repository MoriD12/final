output "instance_ip" {
  value = aws_instance.builder.public_ip
}

output "instance_id" {
  value = aws_instance.builder.id
}

output "az" {
  value = aws_instance.builder.availability_zone
}

output "ami" {
  value = aws_instance.builder.ami
}
