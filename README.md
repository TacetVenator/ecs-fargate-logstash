# ecs-fargate-logstash
A simple demo to deploy Logstash inside an ECS Fargate container


# Next steps

1. Test one task.

2. Make it a module
e.g.  
```hcl
module "logstash_task_1" {
  source = "./modules/logstash-ecs-task"

  logstash_config_file = "path/to/logstash-config-1.conf"
  ecr_repository_url   = "your_ecr_repository_url"
  logstash_image_tag   = "v1"
  // Other necessary parameters
}

module "logstash_task_2" {
  source = "./modules/logstash-ecs-task"

  logstash_config_file = "path/to/logstash-config-2.conf"
  ecr_repository_url   = "your_ecr_repository_url"
  logstash_image_tag   = "v2"
  // Other necessary parameters
}
```

3. Make it scalable.  
e.g.  
```hcl
resource "aws_ecs_service" "example" {
  name            = "example-service"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.example.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["your_subnet_id"]
    security_groups  = ["your_security_group_id"]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_appautoscaling_target" "example" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.example.name}/${aws_ecs_service.example.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}


resource "aws_appautoscaling_policy" "cpu_utilization" {
  name               = "cpu-utilization"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.example.resource_id
  scalable_dimension = aws_appautoscaling_target.example.scalable_dimension
  service_namespace  = aws_appautoscaling_target.example.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70.0

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

```

In this configuration:

max_capacity and min_capacity in the aws_appautoscaling_target resource define the maximum and minimum number of tasks that your service can scale out or in to.  
The target_value in the aws_appautoscaling_policy resource specifies the average CPU utilization your service aims to maintain.  
AWS Auto Scaling adjusts the number of tasks to keep the average CPU utilization around this target. In this example, it's set to 70%, meaning AWS will try to add or remove tasks to keep the CPU utilization around 70%.  
Adjust the max_capacity, min_capacity, and target_value according to your specific application needs and expected workload.

