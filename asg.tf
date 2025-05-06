### --- Launch Template (Blueprint for EC2 Instances) --- ###

resource "aws_launch_template" "web_lt" {
  name_prefix   = "web-server-lt"
  image_id      = "ami-0c614dee691cbbf37"
  instance_type = "t2.micro"

  user_data     = base64encode(file("${path.module}/startup.sh"))

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ASG-WebServer"
    }
  }
}


### --- Auto Scaling Group (ASG) --- ###

resource "aws_autoscaling_group" "web_asg" {
  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  vpc_zone_identifier = aws_subnet.public_subnets[*].id     # use public subnets
  desired_capacity    = 2                                   # nameumber of instances to start with
  min_size            = 1                                   # minimum number of instances
  max_size            = 4                                   # maximum number of instances

  health_check_type         = "EC2"
  health_check_grace_period = 300

  target_group_arns = [aws_lb_target_group.web_tg.arn]      # attach to ALB Target Group
  
  # Enable CloudWatch Detailed Monitoring, tracking number of instances running, pending, and terminating
  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]
}


### --- Auto Scaling Policies (Scale In & Out) --- ###

# Scale up when CPU usage > 50%
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
}

# Scale down when CPU usage < 20%
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
}
