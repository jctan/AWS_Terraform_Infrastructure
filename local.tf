locals {
  name   = var.awsaccountname
  region = var.region

  user_data = <<-EOT
  #!/bin/bash
  echo "Hello Terraform!"
  yum update -y
  yum install -y httpd
  systemctl start httpd
  systemctl enable httpd
  echo $(curl -s http://169.254.169.254/latest/meta-data/instance-id) > /var/www/html/index.html
  usermod -a -G apache ec2-user
  chown -R ec2-user:apache /var/www
  chmod 2775 /var/www
  find /var/www -type d -exec sudo chmod 2775 {} \;
  find /var/www -type f -exec sudo chmod 0664 {} \;
  EOT

  tags = [
    {
      key                 = "Project"
      value               = "assignment"
      propagate_at_launch = true
    },
    {
      key                 = "Purpose"
      value               = "test"
      propagate_at_launch = true
    },
  ]

  tags_as_map = {
    Owner       = "user"
    Environment = "dev"
  }

}