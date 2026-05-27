module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "~> 1.8"

  # File system
  name           = "minecraft-volume"
  creation_token = "minecraft-volume"

  # Mount targets / security group
  mount_targets              = { for k, v in zipmap(module.vpc.azs, module.vpc.public_subnets) : k => { subnet_id = v } }
  security_group_description = "EFS security group for minecraft server"
  security_group_vpc_id      = module.vpc.vpc_id

  security_group_rules = {
    vpc = {
      description = "NFS ingress from ECS service security group"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }

    egress = {
      type        = "egress"
      description = "Allow all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  access_points = {
    vanilla_minecraft = {
      posix_user = {
        gid = 1000
        uid = 1000
      }
      root_directory = {
        path = "/vanilla"
        creation_info = {
          owner_gid   = 1000
          owner_uid   = 1000
          permissions = "755"
        }
      }
    }
  }

  # Backup policy
  enable_backup_policy = false
  # Replication configuration
  create_replication_configuration = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 1.0"

  aliases               = ["efs/minecraft-volume"]
  description           = "EFS customer managed key"
  enable_default_policy = true
}