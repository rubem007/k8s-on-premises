# 6 - Create Security group for public subnet
resource "aws_security_group" "control_plane_sg" {
  name        = "control-plane-sg"
  description = "Firewall rules for EC2"
  vpc_id      = aws_vpc.k8s_on_premises_vpc.id

  ingress {
    description      = "SSH Access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Kubernetes API server"
    from_port        = 6443
    to_port          = 6443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Etcd Server Client API"
    from_port        = 2379
    to_port          = 2380
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Kubelet API"
    from_port        = 10250
    to_port          = 10250
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Kube-scheduler"
    from_port        = 10259
    to_port          = 10259
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Kube-controller-manager"
    from_port        = 10257
    to_port          = 10257
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Calico CNI"
    from_port        = 6783
    to_port          = 6783
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Calico CNI"
    from_port        = 6783
    to_port          = 6784
    protocol         = "udp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "control-plane-sg"
  }
}

resource "aws_security_group" "node_sg" {
  name        = "node-sg"
  description = "Firewall rules for EC2"
  vpc_id      = aws_vpc.k8s_on_premises_vpc.id

  ingress {
    description      = "SSH Access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Kubernetes API server"
    from_port        = 10250
    to_port          = 10250
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "NodePort Services"
    from_port        = 30000
    to_port          = 32767
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "node-sg"
  }
}

resource "aws_network_acl" "k8s_on_premises_acl" {
  vpc_id     = aws_vpc.k8s_on_premises_vpc.id
  subnet_ids = [aws_subnet.k8s_on_premises_subnet_public.id]

  #Ephemerals port
  #   ingress {
  #     protocol   = "tcp"
  #     rule_no    = 100
  #     action     = "allow"
  #     cidr_block = "0.0.0.0/0"
  #     from_port  = 1024
  #     to_port    = 65535
  #   }

  #   ingress {
  #     protocol   = "tcp"
  #     rule_no    = 100
  #     action     = "allow"
  #     cidr_block = "0.0.0.0/0"
  #     from_port  = 22
  #     to_port    = 22
  #   }

  #   egress {
  #     protocol   = "tcp"
  #     rule_no    = 0
  #     action     = "allow"
  #     cidr_block = "-1"
  #     from_port  = 0
  #     to_port    = 0
  #   }

  egress {
    protocol   = "-1"        # "-1" significa "todos os protocolos"
    rule_no    = 100         # Número da regra (deve ser único)
    action     = "allow"     # Permitir tráfego
    cidr_block = "0.0.0.0/0" # Permitir todos os endereços IPv4
    from_port  = 0           # Ignorado quando protocolo é "-1"
    to_port    = 0           # Ignorado quando protocolo é "-1"
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "k8s-on-premises-acl"
  }
}

