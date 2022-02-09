resource "aws_launch_template" "this" {
  name_prefix   = "external-lt-${local.name}-"
  image_id      = data.aws_ami.amazon-linux-2.id
  instance_type = "t3.micro"

  lifecycle {
    create_before_destroy = true
  }
  network_interfaces {
    associate_public_ip_address = true
  }
  vpc_security_group_ids = [module.asg_security_grp.security_group_id]
  user_data  = base64encode(local.user_data)
  key_name = module.key_pair.key_pair_key_name
}

module "autoscaling_group" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"
  # Autoscaling group
  name = "mixed-instance-${local.name}"

  vpc_zone_identifier = module.vpc.public_subnets
  min_size            = 2
  max_size            = 5
  desired_capacity    = 2

  image_id           = data.aws_ami.amazon-linux-2.id
  instance_type      = "t3a.micro"
  capacity_rebalance = true
  user_data_base64  = base64encode(local.user_data)
  target_group_arns = module.alb.target_group_arns
  security_groups          = [module.asg_security_grp.security_group_id]
  key_name = module.key_pair.key_pair_key_name
  block_device_mappings = [
      {
        # Root volume
        device_name = "/dev/xvda"
        no_device   = 0
        ebs = {
          delete_on_termination = true
          encrypted             = true
          volume_size           = 8
          volume_type           = "gp2"
        }
      }
    ]  

  initial_lifecycle_hooks = [
    {
      name                 = "ExampleStartupLifeCycleHook"
      default_result       = "CONTINUE"
      heartbeat_timeout    = 60
      lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
      # This could be a rendered data resource
      notification_metadata = jsonencode({ "hello" = "world" })
    },
    {
      name                 = "ExampleTerminationLifeCycleHook"
      default_result       = "CONTINUE"
      heartbeat_timeout    = 180
      lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
      # This could be a rendered data resource
      notification_metadata = jsonencode({ "goodbye" = "world" })
    }
  ]

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay       = 600
      checkpoint_percentages = [35, 70, 100]
      instance_warmup        = 300
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  # Launch template
  # launch_template = aws_launch_template.this.name
  create_lt              = true
  update_default_version = true


  # Mixed instances
  use_mixed_instances_policy = true
  mixed_instances_policy = {

    override = [
      {
        instance_type     = "t3a.nano"
        weighted_capacity = "1"
      },
      {
        instance_type     = "t3a.micro"
        weighted_capacity = "2"
      },
    ]
  }

  tags        = local.tags
  tags_as_map = local.tags_as_map
}