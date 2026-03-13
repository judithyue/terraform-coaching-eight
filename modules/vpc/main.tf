# the vpc
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  # merge(base_tags, extra_tags)
  tags = merge(var.tags, {
    Name = "${var.vpc_prefix}-vpc-ju" # Adds "fluffy-uat-vpc" as a searchable tag      
  })
}

# numner of AZ in a region
locals {
  az_count = length(data.aws_availability_zones.available.names)
}

resource "aws_subnet" "managed_subnets" {
  for_each = var.subnet_config

  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[each.value.netnum % local.az_count]

  # 10.0.0.0/16 + 8 bits = /24. The netnum sets the 3rd octet.
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, each.value.netnum)

  # This flag makes it a "Public" subnet by assigning IPs to instances
  map_public_ip_on_launch = each.value.public

  tags = merge(var.tags, {
    Name = "${var.vpc_prefix}-${each.key}-sn-ju" # fluffy-uat-public_1-sn
  })
}

# igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {
    Name = "${var.vpc_prefix}-igw-ju" # Adds "fluffy-uat--igw-ju" as a searchable tag      
  })
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  # This matches the manual "0.0.0.0/0" route you created
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.tags, {
    Name = "${var.vpc_prefix}-public-rt-ju" # fluffy-uat-public-rt-ju      
  })
}

resource "aws_route_table_association" "public_assoc" {
  # We filter the previous 'managed_subnets' to only grab public ones
  for_each = {
    for k, v in var.subnet_config : k => v if v.public == true
  }

  subnet_id      = aws_subnet.managed_subnets[each.key].id
  route_table_id = aws_route_table.public_rt.id
}



