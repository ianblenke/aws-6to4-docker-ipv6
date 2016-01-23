variable Project {
  description = "Project name"
}

variable Environment {
  description = "Lifecycle (dev, qa, prod)"
}

variable aws_access_key_id {
  description = "AWS Access Key"
}

variable aws_secret_access_key {
  description = "AWS Secret Key"
}

variable aws_region {
  description = "AWS Region"
  default = "us-east-1"
}

variable vpc_network_cidr {
  description = "CIDR block for VPC"
  default = "10.1.0.0/16"
}

variable vpc_subnet_network_bits {
  description = "Number of bits in addition to vpc_network_cidr used for network part of subnet mask"
  default = 6 
}

variable vpc_subnet_count {
  description = "Number of subnets to create"
  default = 1
}

variable "aws_availability_zones" {
  description = "Comma separated list of availability zones to use by region"
  default = {
    "us-east-1" = "us-east-1a,us-east-1b,us-east-1c"
  }
}

# From: http://cloud-images.ubuntu.com/locator/ec2/
# Search for: trusty hvm:ebs-ssd
# As of: 2016-01-23
#
# ap-northeast-1	trusty	14.04 LTS	amd64	hvm:ebs-ssd	20160114.5	ami-a21529cc	hvm
# ap-southeast-1	trusty	14.04 LTS	amd64	hvm:ebs-ssd	20160114.5	ami-25c00c46	hvm
# eu-central-1		trusty	14.04 LTS	amd64	hvm:ebs-ssd	20160114.5	ami-87564feb	hvm
# eu-west-1		trusty	14.04 LTS	amd64	hvm:ebs-ssd	20160114.5	ami-f95ef58a	hvm
# sa-east-1		trusty	14.04 LTS	amd64	hvm:ebs-ssd	20160114.5	ami-0fb83963	hvm
# us-east-1		trusty	14.04 LTS	amd64	hvm:ebs-ssd	20160114.5	ami-fce3c696	hvm
# us-west-1		trusty	14.04 LTS	amd64	hvm:ebs-ssd	20160114.5	ami-06116566	hvm
# cn-north-1		trusty	14.04 LTS	amd64	hvm:ebs-ssd	20151218	ami-0679b06b	hvm
# us-gov-west-1		trusty	14.04 LTS	amd64	hvm:ebs-ssd	20151019	ami-30b8da13	hvm
# ap-southeast-2	trusty	14.04 LTS	amd64	hvm:ebs-ssd	20160114.5	ami-6c14310f	hvm
# us-west-2		trusty	14.04 LTS	amd64	hvm:ebs-ssd	20160114.5	ami-9abea4fb	hvm
#
variable "ami" {
    description = "These are HVM EBS-SSD instance types. If you change these, make sure it is compatible with your chosen instance type, not all AMIs allow all instance types"
    default = {
        ap-northeast-1-ubuntu-14.04 = "ami-a21529cc"
        ap-southeast-1-ubuntu-14.04 = "ami-25c00c46"
        eu-central-1-ubuntu-14.04 = "ami-87564feb"
        eu-west-1-ubuntu-14.04 = "ami-f95ef58a"
        sa-east-1-ubuntu-14.04 = "ami-0fb83963"
        us-east-1-ubuntu-14.04 = "ami-fce3c696"
        us-west-1-ubuntu-14.04 = "ami-06116566"
        cn-north-1-ubuntu-14.04 = "ami-0679b06b"
        us-gov-west-1-ubuntu-14.04 = "ami-30b8da13"
        ap-southeast-2-ubuntu-14.04 = "ami-6c14310f"
        us-west-2-ubuntu-14.04 = "ami-9abea4fb"
    }
}

variable aws_instance_count_6to4 {
    description = "The number of 6to4 instances to create"
    default = "1"
}

variable aws_instance_type_6to4 {
    description = "AWS instance type to use for 6to4 servers"
    default = "t2.micro"
}

variable linux_distro_name_6to4 {
    description = "AWS instance linux distro name to use for 6to4 servers"
    default = "ubuntu"
}

variable linux_distro_version_6to4 {
    description = "AWS instance linux distro version to use for 6to4 servers"
    default = "14.04"
}

variable ssh_key_path_6to4 {
    description = "Path to ssh private key file"
    default = "../secrets/id_rsa-6to4"
}

variable ebs_root_volume_size_6to4 {
    description = "EBS Root Volume Size for 6to4 servers"
    default = "10"
}

