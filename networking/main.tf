## Networking/main.tf ##

data "aws_availability_zones" "available" {}


resource "random_integer" "random" {
  min = 1
  max = 100
}

resource "random_shuffle" "az" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-${random_integer.random.id}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "subnet" {
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.az.result[count.index]

  tags = {
    Name = "public_subnet_${count.index + 1}"
  }
}

resource "aws_route_table_association" "public_rt_table_assoc" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.subnet.*.id[count.index]
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_subnet" "subnet_private" {
  count                   = var.private_sn_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone       = random_shuffle.az.result[count.index]

  tags = {
    Name = "private_subnet_${count.index + 1}"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "public_Gateway"
  }
}

resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Public Rote"
  }
}

resource "aws_route" "deafult_route" {
  route_table_id         = aws_route_table.route_table_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

resource "aws_default_route_table" "private_rt_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_security_group" "public_sg" {
  for_each    = var.security_groups
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.vpc.id
  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "subnet_group" {
  count      = var.db_subnet_group == true ? 1 : 0
  name       = "rds_subnet_group"
  subnet_ids = aws_subnet.subnet_private.*.id
  tags = {
    Name = "rds_subnet"
  }
}

