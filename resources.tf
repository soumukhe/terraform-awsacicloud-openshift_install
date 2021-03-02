





# Create the vpc
resource "aws_vpc" "vpc-tf" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpcname
  }

}

# Create the subnet for the vpc
resource "aws_subnet" "terraform-subnet1" {
  vpc_id     = aws_vpc.vpc-tf.id
  cidr_block = var.subnet

  tags = {
    Name = var.subnetname
  }
}

/*
# Test only to get output.  You can get the same info from terraform.tfstate
output "routetable" {
  value = aws_vpc.vpc-tf.default_route_table_id
}

*/

# Create the IGW
resource "aws_internet_gateway" "igw-tf" {
  vpc_id = aws_vpc.vpc-tf.id

  tags = {
    Name = var.igw_name
  }
}

# Associate the route table created earlier with IGW
resource "aws_route" "default_to_igw" {
  route_table_id         = aws_vpc.vpc-tf.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw-tf.id

}

#  Notice that this will upload my public key to AWS and use it for the EC2s.  This way, I an login with my private keys.
resource "aws_key_pair" "loginkey" {
  key_name = "login-key"
  #public_key = file("${path.module}/.certs/id_rsa.pub") # #  path.module is in relation to the current directory
  public_key = file("~/.ssh/id_rsa.pub")
}



# create the security group
resource "aws_security_group" "allow_all" {
  name        = "allow_all-sgroup"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.vpc-tf.id

  ingress {
    description = "All Traffic Inbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.securitygroupname
  }

}

# Associate the security group with the instance
resource "aws_network_interface_sg_attachment" "sg_attachment" {
  count                = var.num_inst
  security_group_id    = aws_security_group.allow_all.id
  network_interface_id = aws_instance.sm-terraform1-ec2[count.index].primary_network_interface_id
}

# spin up the aws instance
resource "aws_instance" "sm-terraform1-ec2" {
  ami                         = data.aws_ami.ubuntu.id # this equates to the current ami name  
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.terraform-subnet1.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.loginkey.key_name
  count                       = var.num_inst
  tags = {
    #Name = element(var.tags, count.index) #  this function will give first tag to be firstec2,  2nd tag will be secondec2   # element (list, index)
    Name = "${var.instancename}-${count.index}"
  }
}


resource "null_resource" "waitTime1" {
  depends_on = [aws_instance.sm-terraform1-ec2]

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

resource "null_resource" "scp" {
  count      = var.num_inst
  depends_on = [null_resource.waitTime1]
  triggers = {
    build_number = timestamp()
  }


  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${path.module}/acc-provision_5.0.1.0-57_amd64.deb ubuntu@${aws_instance.sm-terraform1-ec2[count.index].public_ip}:/tmp/"
  }

}

resource "null_resource" "waitTime2" {
  depends_on = [null_resource.scp]

  provisioner "local-exec" {
    command = "sleep 30"
  }
}

resource "null_resource" "update" {
  count      = var.num_inst
  depends_on = [null_resource.waitTime2]
  triggers = {
    build_number = timestamp()
  }
  provisioner "remote-exec" {
    inline = [
      #"sudo add-apt-repository universe",
      "sudo apt-get update -y",
      "sudo sleep 180",
      "sudo apt-get upgrade -y"
    ]

    connection {
      type = "ssh"
      user = "ubuntu"
      #private_key = file("${path.module}/.certs/id_rsa")
      private_key = file("~/.ssh/id_rsa")
      host        = aws_instance.sm-terraform1-ec2[count.index].public_ip
    }
  }

}


resource "null_resource" "waitTime3" {
  depends_on = [null_resource.scp]

  provisioner "local-exec" {
    command = "sleep 120"
  }
}

resource "null_resource" "waitTime4" {
  depends_on = [null_resource.waitTime3]

  provisioner "local-exec" {
    command = "sleep 120"
  }
}


resource "null_resource" "dpkg" {
  count      = var.num_inst
  depends_on = [null_resource.waitTime4]
  triggers = {
    build_number = timestamp()
  }
  provisioner "remote-exec" {
    inline = [
      "sudo dpkg -i /tmp/acc-provision_5.0.1.0-57_amd64.deb",
      "sudo sleep 60",
      "sudo apt --fix-broken install -y",
      "sudo sleep 60",
      "sudo apt install -y awscli",
    ]

    connection {
      type = "ssh"
      user = "ubuntu"
      #private_key = file("${path.module}/.certs/id_rsa")
      private_key = file("~/.ssh/id_rsa")
      host        = aws_instance.sm-terraform1-ec2[count.index].public_ip
    }
  }

}
