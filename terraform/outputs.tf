output "control_plane_public_ip" {
  value = aws_instance.control_plane.public_ip
}

output "control_plane_private_ip" {
  value = aws_instance.control_plane.private_ip
}

output "node_public_ips" {
  value = tolist(aws_instance.node[*].public_ip)
}

output "node_private_ips" {
  value = tolist(aws_instance.node[*].private_ip)
}