terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.58.0"
    }
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "final-task-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["us-east-1a"]
  public_subnets = ["10.0.101.0/24"]
}

#Control Node SG
resource "aws_security_group" "SG_control_node" {
  name        = "SG-Control-Node"
  description = "Security group for Ansible control node"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "SG_control_ingress_rule" {
  security_group_id = aws_security_group.SG_control_node.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  #cidr_blocks       = ["18.206.107.24/29"]
  protocol  = "tcp"
  from_port = 22
  to_port   = 22
}

resource "aws_security_group_rule" "SG_control_egress_rule" {
  security_group_id = aws_security_group.SG_control_node.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
}

#Nodes SG
resource "aws_security_group" "SG_node" {
  name        = "SG-Node"
  description = "Security group for Ansible node"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "SG_node_ingress_rule_ip" {
  security_group_id = aws_security_group.SG_node.id
  type              = "ingress"
  cidr_blocks       = ["18.206.107.24/29"]
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_security_group_rule" "SG_node_ingress_rule_sg" {
  security_group_id        = aws_security_group.SG_node.id
  type                     = "ingress"
  source_security_group_id = aws_security_group.SG_control_node.id
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
}

resource "aws_security_group_rule" "SG_node_egress_rule" {
  security_group_id = aws_security_group.SG_node.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
}

resource "aws_instance" "control_node_instance" {
  ami                         = "ami-0a0e5d9c7acc336f1"
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.SG_control_node.id]
  associate_public_ip_address = true
  key_name                    = "ansible"

  tags = {
    Name = "control.example.com"
  }

  user_data = file("${path.module}/scripts/control.sh")
}

resource "aws_instance" "task-instance" {
  count                       = 2
  ami                         = "ami-0a0e5d9c7acc336f1"
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.SG_node.id]
  associate_public_ip_address = true
  key_name                    = "ansible"

  tags = {
    Name = "node${count.index + 1}.example.com"
  }

  user_data = file("${path.module}/scripts/node.sh")
}