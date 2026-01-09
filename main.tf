provider "aws" {
    region = "ca-central-1"
}

# =========================================================================
# 1. REMOTE BACKEND CONFIGURATION
# =========================================================================
# This tells Terraform: "Save the state for THIS project in the bucket from Project 1"

terraform {
    backend "s3" {
        bucket = "iftekhar-tf-state-2026"
        key = "project2/hub-spoke/terraform.tfstate"
        region = "ca-central-1"
        encrypt = true
        dynamodb_table = "terraform-lock"
    }
}
# =========================================================================
# 2. THE VPCs (The Networks)
# =========================================================================

# --- HUB VPC (Shared Services) ---

resource "aws_vpc" "hub_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {Name = "Hub VPC"}

}

resource "aws_subnet" "hub_subnet" {
    vpc_id = aws_vpc.hub_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ca-central-1a"
    tags = {Name = "Hub Subnet"}
}

# --- DEV VPC (The Playground) ---
resource "aws_vpc" "dev_vpc" {
    cidr_block = "10.1.0.0/16"
    tags = {Name = "Dev VPC"}
}

resource "aws_subnet" "dev_subnet" {
    vpc_id = aws_vpc.dev_vpc.id
    cidr_block = "10.1.1.0/24"
    availability_zone = "ca-central-1a"
    tags = {Name = "Dev Subnet"}
}

#--- PROD VPC (The Money Maker) 
resource "aws_vpc" "prod_vpc" {
    cidr_block = "10.2.0.0/16"
    tags = {Name = "Prod VPC"}
}

resource "aws_subnet" "prod_subnet" {
    vpc_id = aws_vpc.prod_vpc.id
    cidr_block = "10.2.1.0/24"
    availability_zone = "ca-central-1a"
    tags = {Name = "Prod Subnet"}
}

# =========================================================================
# 3. The transit gateway
# =========================================================================

resource "aws_ec2_transit_gateway" "tgw" {
    description = "My hub and spoke router"
    tags = {Name = "TGW"}
}

# =========================================================================
# 4. ATTACHMENTS (Plugging the cables in)
# =========================================================================

resource "aws_ec2_transit_gateway_vpc_attachment" "hub_attachment" {
    subnet_ids = [aws_subnet.hub_subnet.id]
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
    vpc_id = aws_vpc.hub_vpc.id 
    tags = {Name = "Hub Attachment"}
}

resource "aws_ec2_transit_gateway_vpc_attachment" "dev_attachment" {
    subnet_ids = [aws_subnet.dev_subnet.id]
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
    vpc_id = aws_vpc.dev_vpc.id
    tags = {Name = "Dev Attachment"}
}

resource "aws_ec2_transit_gateway_vpc_attachment" "prod_attachment" {
    subnet_ids = [aws_subnet.prod_subnet.id]
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
    vpc_id = aws_vpc.prod_vpc.id
    tags = {Name = "Prod Attachment"}

}

# =========================================================================
# 5. ROUTES (Routing traffic between the networks)
# =========================================================================

# --- HUB Routing ---

resource "aws_route_table"  "hub_rt" {
    vpc_id = aws_vpc.hub_vpc.id 
    route {
        cidr_block = "10.0.0.0/8" # send all internal traffic to the TGW
        transit_gateway_id = aws_ec2_transit_gateway.tgw.id 
    }
    tags = {Name = "Hub RT"}
}

resource "aws_route_table_association" "hub_assoc" {
    subnet_id = aws_subnet.hub_subnet.id
    route_table_id = aws_route_table.hub_rt.id 
}

# --- DEV Routing ---

resource "aws_route_table" "dev_rt" {
    vpc_id = aws_vpc.dev_vpc.id
    route {
        cidr_block = "10.0.0.0/8" # send all internal traffic to the TGW
        transit_gateway_id = aws_ec2_transit_gateway.tgw.id 
    }
    tags = {Name = "Dev RT"}
}

resource "aws_route_table_association" "dev_assoc" {
    subnet_id = aws_subnet.dev_subnet.id
    route_table_id = aws_route_table.dev_rt.id
}

# --- PROD Routing ---

resource "aws_route_table" "prod_rt" {
    vpc_id = aws_vpc.prod_vpc.id
    route {
        cidr_block = "10.0.0.0/8" # send all internal traffic to the TGW
        transit_gateway_id = aws_ec2_transit_gateway.tgw.id 
    }
    tags = {Name = "Prod RT"}
}

resource "aws_route_table_association" "prod_assoc" {
    subnet_id = aws_subnet.prod_subnet.id
    route_table_id = aws_route_table.prod_rt.id
}
