


#Step8 - Create datasources,tf file and add ec2 AMI image to be created in this file

#Step9 - Add aws keypair for login
/*
 - Open terninal and execute command ; ssh-keygen -t ed25519
 - Enter filename with path ; /home/fatih/.ssh/fatih_key
 - two files will be created in specified path ; fatih_key and fatih_key.pub
*/

resource "aws_key_pair" "fatih_auth" {
  key_name   = var.key_name
  public_key = file("~/.ssh/fatih_key.pub")

}

#Step10 - Create EC2 instance
resource "aws_instance" "dev_node" {
  instance_type          = var.instance_type
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.fatih_auth.id
  vpc_security_group_ids = var.security_group_id
  subnet_id              = var.subnet_id
  #add user data from userdata.tpl file. this userdata installs required software
  user_data = file("${path.module}/userdata_apache.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "${var.node_name}-dev-node"
  }
  /*
    In Terraform, a provisioner is a feature that allows you to execute scripts or commands on a remote resource after it has been created or destroyed. 
    Provisioners are useful for performing tasks that cannot be managed directly through Terraform configuration, 
    such as installing software, configuring applications, or setting up the environment on the remote resource.
    */
  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu"
      identityfile = "~/.ssh/fatih_key"
    })
    interpreter = var.host_os == "linux" ? ["bash", "-c"] : ["Powershell", "-Command"]
  }


}
