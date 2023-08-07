module "networking" {
  source = "./networking"
}

module "master-dev" {
  source            = "./compute"
  security_group_id = [module.networking.security_group_id]
  subnet_id         = module.networking.subnet_id
  host_os           = var.host_os
  node_name         = "master"
  key_name          = "masternode-key"
  instance_type     = "t2.micro"
}

module "slave-dev" {
  source            = "./compute"
  security_group_id = [module.networking.security_group_id]
  subnet_id         = module.networking.subnet_id
  host_os           = var.host_os
  node_name         = "slave"
  key_name          = "slavenode-key"
  instance_type     = "t2.micro"
}