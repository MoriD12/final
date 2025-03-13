output "instance_ip" {
  value = aws_instance.builder.public_ip
}

output "az" {
  value = aws_instance.builder.availability_zone
}

output "az" {
  value = aws_instance.builder.ami
}
