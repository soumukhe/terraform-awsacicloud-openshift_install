# this is the file that defines the variables.  The values should be specified in terraform.tfvars


variable "instance_type" { default = "t2.micro" }

variable "region" {
  default = "us-east-1"
}

variable "tags" {
  type    = list
  default = ["sm-terec2-1", "sm-terec2-2", "sm-terec2-3", "sm-terec2-4", "sm-terec2-5"]
}

variable "instancename" {
  type    = string
  default = "OpenshiftInstallUbuntu"
}


variable "vpcname" {
  type    = string
  default = "openshiftInstall-vpc"
}

variable "cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet" {
  type    = string
  default = "10.0.1.0/16"
}


variable "subnetname" {
  type    = string
  default = "OpenshiftInstall-subnet"
}

variable "securitygroupname" {
  type    = string
  default = "openshiftInstall-subnet-name"
}

variable "owners" {
  type    = list
  default = ["none"]
}


variable "igw_name" {
  type    = string
  default = "ipenshiftInstall-IGW0"
}

variable "num_inst" {
  type    = number
  default = 1
}

variable "values" {
  type    = list
  default = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
}
