resource "aws_security_group" "worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id


  ingress {
    description       = "allow inbound traffic from eks"
    from_port         = 443
    protocol          = "tcp"
    to_port           = 443
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.jump_server_sg.id]
  }

  egress {
    description       = "allow outbound traffic to anywhere"
    from_port         = 0
    protocol          = "-1"
    to_port           = 0
    cidr_blocks       = ["0.0.0.0/0"]
  }
}



resource "aws_security_group" "jump_server_sg" {
  name_prefix = "jump_server_management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port         = 22
    protocol          = "tcp"
    to_port           = 22
    cidr_blocks       = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule for HTTPS traffic (port 443)
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


