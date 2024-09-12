resource "aws_instance" "jump_server" {
  ami = ""
  instance_type = "t2.micro"
  security_groups = [aws_security_group.jump_server_sg]
  subnet_id = module.vpc.private_subnets[1]

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
