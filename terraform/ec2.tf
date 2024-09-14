resource "aws_instance" "jump_server" {
  ami = "ami-0e86e20dae9224db8"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.jump_server_sg.id]
  subnet_id = module.vpc.public_subnets[1]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.jump_server_profile.id


  user_data = <<-EOF
     #!/bin/bash
     #install aws cli
     sudo apt install curl unzip -y
     curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
     unzip awscliv2.zip
     sudo ./aws/install

     #!/bin/bash
     #install kubectl
     sudo apt update
     curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
     chmod +x kubectl
     sudo mv kubectl /usr/local/bin
     kubectl version --client

     #install helm
     sudo snap install helm --classic
  EOF
}

resource "aws_iam_instance_profile" "jump_server_profile" {
  name = "jump-server-instance-profile"
  role = aws_iam_role.eks_cluster_role.name
}
