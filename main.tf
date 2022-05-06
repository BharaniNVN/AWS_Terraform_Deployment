## root/main.tf #

module "networking" {
  source           = "./networking"
  vpc_cidr         = "10.123.0.0/16"
  security_groups  = local.security_groups
  public_sn_count  = 2
  private_sn_count = 3
  max_subnets      = 20
  public_cidrs     = [for i in range(2, 255, 2) : cidrsubnet("10.123.0.0/16", 8, i)]
  private_cidrs    = [for i in range(1, 255, 2) : cidrsubnet("10.123.0.0/16", 8, i)]
  db_subnet_group  = true
}

module "database" {
  source                 = "./database"
  db_storage             = 10
  db_engine_version      = "5.7.22"
  db_instance_class      = "db.t2.micro"
  db_name                = var.db_name
  dbuser                 = var.dbuser
  dbpassword             = var.dbpassword
  db_subnet_group_name   = module.networking.db_subnet_group_name[0]
  vpc_security_group_ids = module.networking.db_security_group
  db_identifier          = "aws-db"
  skip_db_snapshot       = true

}

module "loadbalancer" {
  source                 = "./loadbalancer"
  public_subnets         = module.networking.public_subnets
  public_sg              = module.networking.public_sg
  tg_port                = 80
  tg_protocol            = "HTTP"
  vpc_id                 = module.networking.vpc_id
  lb_healthy_threshold   = 2
  lb_unhealthy_threshold = 2
  lb_timeout             = 3
  lb_interval            = 30
  listner_port           = 80
  listner_protocol       = "HTTP"
}

module "compute" {
  source          = "./compute"
  instance_count  = 1
  instance_type   = "t3.micro"
  public_sg       = module.networking.public_sg
  public_subnets  = module.networking.public_subnets
  vol_size        = 10
  key_name        = "awskey"
  public_key_path = "/home/ubuntu/.ssh/awskey.pub"
  user_data_path  = "${path.root}/userdata.tpl"
  dbuser          = var.dbuser
  dbpassword          = var.dbpassword
  db_name          = var.db_name
  db_endpoint     = module.database.db_endpoint
  lb_target_group_arn = module.loadbalancer.lb_target_group_arn
}