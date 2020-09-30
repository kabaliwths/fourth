#################################################
########  AUTOSCALING FOR ECS INSTANCES #########
#################################################

resource "aws_autoscaling_group" "main" {
  name = "ecs-fourthline"

  launch_configuration = aws_launch_configuration.ecs-launch-configuration.id
  termination_policies = ["OldestLaunchConfiguration", "Default"]
  vpc_zone_identifier  = module.vpc.public_subnets

  desired_capacity = 1
  max_size         = 3
  min_size         = 1

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "ecs-fourthline"
    propagate_at_launch = true
  }
}



resource "aws_autoscaling_policy" "scale_up" {
  name                   = "ecs-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  cooldown               = 200
  autoscaling_group_name = join("", aws_autoscaling_group.main.*.name)
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "ecs-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  cooldown               = 200
  autoscaling_group_name = join("", aws_autoscaling_group.main.*.name)
}



resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu utilization is high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 90

  dimensions = {
    AutoScalingGroupName = join("", aws_autoscaling_group.main.*.name)
  }

  alarm_description = "Scale up if CPU utilization is above 90 for 200 seconds"
  alarm_actions     = [join("", aws_autoscaling_policy.scale_up.*.arn)]
}


resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu utilization is low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 10

  dimensions = {
    AutoScalingGroupName = join("", aws_autoscaling_group.main.*.name)
  }

  alarm_description = "Scale down if the CPU utilization is below 10 for 200 seconds"
  alarm_actions     = [join("", aws_autoscaling_policy.scale_down.*.arn)]
}