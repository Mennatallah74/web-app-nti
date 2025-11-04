provider "aws"{
    region = "eu-central-1"
}


resource "aws_vpc" "myapp-vpc"{
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }

}

module "myapp-subnet"{
source = "./modules/subnet"
subnet_cidr_block = var.subnet_cidr_block
avail_zone = var.avail_zone
env_prefix = var.env_prefix
vpc_id = aws_vpc.myapp-vpc.id
default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
}


module "myapp-server"{
source = "./modules/webserver"
vpc_id = aws_vpc.myapp-vpc.id
env_prefix = var.env_prefix
public_key_location = var.public_key_location
instance_type = var.instance_type
subnet_id = module.myapp-subnet.subnet.id
avail_zone = var.avail_zone
private_key_location = var.private_key_location
}

resource "aws_ecr_repository" "my_ecr_repo" {
  name                 = "my-ecr-repo"
  image_tag_mutability = "MUTABLE"  # or "IMMUTABLE" based on your requirement
  image_scanning_configuration {
    scan_on_push = true
  }
}