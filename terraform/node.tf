resource "aws_instance" "node" {
  count                       = 2
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.k8s_on_premises_subnet_public.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.node_sg.id]
  key_name                    = aws_key_pair.k8s_on_premises_key_pair.key_name

  tags = {
    Name = "node-${count.index}"
  }
}