provider "aws" {
  //access_key = "${var.aws_access_key}"
  //secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"

 #  version = "~> 2.41"
}


#data "aws_ami" "ubuntu" {   // need to change
 # most_recent = true

  #filter {
   # name   = "name"
    #values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  #}

  #filter {
   # name   = "virtualization-type"
    #values = ["hvm"]
  #}

  #owners = ["099720109477"] # Canonical
#}

#psn, igw,routing rules
resource "aws_default_vpc" "default" {}

resource "aws_instance" "bastion" {
//  region = "us-west-1"
  ami                         = "ami-969ab1f6"  //"${var.bastion_ami}"
  instance_type               = "t2.micro"
  security_groups             = ["${aws_security_group.ucas-bastion-sg.name}"]
  //associate_public_ip_address = true

  tags = {
      Name = "UCAS BASTION HOST"
  }
}

resource "aws_eip" "bastion_eip" {
    vpc = true
    instance = "${aws_instance.bastion.id}"
    
}
resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.bastion.id}"
  allocation_id = "${aws_eip.bastion_eip.id}"
}


resource "aws_security_group" "ucas-bastion-sg" {
  name   = "bastion-security-group"
  vpc_id = "${aws_default_vpc.default.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]    // Need to update with ip range..

  }

  egress {
    protocol    = -1
    from_port   = 0 
    to_port     = 0 
    cidr_blocks = ["0.0.0.0/0"]    // Need to update with ip range..
  }
}


output "bastion_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}

output "elastic_ip" {
  value = "${aws_eip.bastion_eip.public_ip}"
}
