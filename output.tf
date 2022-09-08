output "bastion-public-ip" {

  value = aws_instance.bastion.public_ip
}

output "frontend-public-ip" {

  value = aws_instance.frontend.public_ip
}

output "frontend-private-ip" {

  value = aws_instance.frontend.private_ip
}

output "backend-private-ip" {

  value = aws_instance.backend.private_ip
}
