### --- CloudWatch Alarm for High CPU Usage --- ###

# If CPU > 50% for 2 minutes, Auto Scaling will add an instance
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "High-CPU-Usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 50  # alarm when CPU > 50%
  alarm_description   = "Triggers when CPU is above 50% for 2 minutes"
  actions_enabled     = true
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }
  alarm_actions = [aws_autoscaling_policy.scale_out.arn]  # triggers Auto Scaling
}



### --- CloudWatch Alarm for Low CPU Usage --- ###

resource "aws_cloudwatch_metric_alarm" "low_cpu_alarm" {
  alarm_name          = "Low-CPU-Usage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 20  # scale in when CPU < 20%
  alarm_description   = "Triggers when CPU is below 20% for 2 minutes"
  actions_enabled     = true
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }
  alarm_actions = [aws_autoscaling_policy.scale_in.arn]  # remove an instance
}
