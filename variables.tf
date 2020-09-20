# variables.tf
variable "aws_access_key" {
    type = string
    default = "AKIAJ7UYKY7TI2K4PE2A"
}
variable "aws_secret_key" {
    type = string
    default = "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"
}
variable "profile" {
    default = "hita"
}
variable "aws_region" {
    default = "ap-south-1"
}
variable "availabilityZone" {
     default = "ap-south-1"
}
variable "instanceTenancy" {
    default = "default"
}
variable "dnsSupport" {
    default = true
}
variable "dnsHostNames" {
    default = true
}
variable "aws_key_path" {
    type = string
    default = "./"
}
variable "private_key_path" {
    type = string
     default = "./"
}
variable "public_key_path" {
    type = string
    default = "./"
}
variable "aws_key_name" {
    type = string
    default = "key2"
}
variable "ec2_user" {
  default = "ec2_user"
}
variable "amis" {
    default = "ami-0447a12f28fddb066"
}
variable "wordpressami" {
    default = "ami-09a7bbd08886aafdf"
}
variable "mysqlami" {
    default = "ami-78166b17"
}
variable "wpinstance" {
    default = "t2.medium"
}
variable "mysqlinstance" {
    default = "t2.micro"
}
variable "availability_zone_names" {
  type    = list(string)
  default = ["ap-south-1"]
}
variable "pub_availabilityZone" {
     default = "ap-south-1a"
}
variable "pvt_availabilityZone" {
     default = "ap-south-1b"
}
variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "192.168.0.0/16"
}

variable "public_subnet_cidr" {
    default = "192.168.0.0/24"
}

variable "private_subnet_cidr" {
    default = "192.168.1.0/24"
}
variable "ingress_cidr" {
    type = list
    default = [ "0.0.0.0/0" ]
}
variable "egress_cidr" {
    type = list
    default = [ "0.0.0.0/0" ]
}
variable "route_cidr" {
    type = list
    default = [ "0.0.0.0/0" ]
}
# end of variables.tf
