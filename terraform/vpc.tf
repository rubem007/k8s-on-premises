# 1 - Create VPC
resource "aws_vpc" "k8s_on_premises_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "k8s-on-premises-vpc"
  }
}

# 2 - Create Subnet for VPC
resource "aws_subnet" "k8s_on_premises_subnet_public" {
  vpc_id     = aws_vpc.k8s_on_premises_vpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "k8s-on-premises-subnet-public"
  }
}

resource "aws_subnet" "k8s_on_premises_subnet_private" {
  vpc_id     = aws_vpc.k8s_on_premises_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "k8s-on-premises-subnet-private"
  }
}

# 3 - Create Internet Gateway and attach to VPC
resource "aws_internet_gateway" "k8s_on_premises_igw" {
  vpc_id = aws_vpc.k8s_on_premises_vpc.id

  tags = {
    Name = "k8s-on-premises-igw"
  }
}

# PUBLIC IP
resource "aws_eip" "k8s_on_premises_nat_eip" {

  depends_on = [aws_internet_gateway.k8s_on_premises_igw]

  tags = {
    Name = "k8s-on-premises-nat-eip"
  }
}

# 4 - Create Nat Gateway and associate a subnet
resource "aws_nat_gateway" "k8s_on_premises_nat_gtw" {
  allocation_id = aws_eip.k8s_on_premises_nat_eip.id
  subnet_id     = aws_subnet.k8s_on_premises_subnet_public.id

  tags = {
    Name = "k8s-on-premises-nat-gtw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.k8s_on_premises_igw]
}

# 5 - Create Route table for public subnet
resource "aws_route_table" "k8s_on_premises_rt_public" {
  vpc_id = aws_vpc.k8s_on_premises_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_on_premises_igw.id
  }

  tags = {
    Name = "k8s-on-premises-rt-public"
  }
}

resource "aws_route_table_association" "k8s_on_premises_rt_public_a" {
  subnet_id      = aws_subnet.k8s_on_premises_subnet_public.id
  route_table_id = aws_route_table.k8s_on_premises_rt_public.id
}

# 5.1 - Create Route table for private subnet
resource "aws_route_table" "k8s_on_premises_rt_private" {
  vpc_id = aws_vpc.k8s_on_premises_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.k8s_on_premises_nat_gtw.id
  }

  tags = {
    Name = "k8s-on-premises-rt-private"
  }
}

resource "aws_route_table_association" "k8s_on_premises_rt_private_a" {
  subnet_id      = aws_subnet.k8s_on_premises_subnet_private.id
  route_table_id = aws_route_table.k8s_on_premises_rt_private.id
}