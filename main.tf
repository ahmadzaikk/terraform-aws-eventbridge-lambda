locals {
  eventbridge_rules = flatten([
    for index, rule in var.rules :
    merge(rule, {
      "name" = index
      "Name" = var.append_rule_postfix ? "${replace(index, "_", "-")}-rule" : index
    })
  ])
  eventbridge_targets = flatten([
    for index, rule in var.rules : [
      for target in var.targets[index] :
      merge(target, {
        "rule" = index
        "Name" = var.append_rule_postfix ? "${replace(index, "_", "-")}-rule" : index
      })
    ] if length(var.targets) != 0
  ])
  eventbridge_connections = flatten([
    for index, conn in var.connections :
    merge(conn, {
      "name" = index
      "Name" = var.append_connection_postfix ? "${replace(index, "_", "-")}-connection" : index
    })
  ])
  eventbridge_api_destinations = flatten([
    for index, dest in var.api_destinations :
    merge(dest, {
      "name" = index
      "Name" = var.append_destination_postfix ? "${replace(index, "_", "-")}-destination" : index
    })
  ])
}

resource "aws_cloudwatch_event_rule" "schedule" {
    name = var.name
    event_bus_name = var.event_bus_name
    description = var.description
    schedule_expression = var.schedule_expression
    depends_on = [aws_cloudwatch_event_bus.this]
    event_pattern = var.event_pattern
}

#resource "aws_cloudwatch_event_target" "schedule_lambda" {
 #   rule = aws_cloudwatch_event_rule.schedule.name
  #  event_bus_name = var.event_bus_name
   # target_id = "processing_lambda"
    #arn = var.arn
    #role_arn = var.role_arn
#}

resource "aws_cloudwatch_event_target" "this" {
  for_each = { for k, v in local.eventbridge_targets : v.name => v if var.create && var.create_targets }

  event_bus_name = var.create_bus ? aws_cloudwatch_event_bus.this[0].name : var.bus_name

  rule = each.value.Name
  arn  = lookup(each.value, "destination", null) != null ? aws_cloudwatch_event_api_destination.this[each.value.destination].arn : each.value.arn

  role_arn = can(length(each.value.attach_role_arn) > 0) ? each.value.attach_role_arn : (try(each.value.attach_role_arn, null) == true ? aws_iam_role.eventbridge[0].arn : null)

  target_id  = lookup(each.value, "target_id", null)
  input      = lookup(each.value, "input", null)
  input_path = lookup(each.value, "input_path", null)

  dynamic "run_command_targets" {
    for_each = try([each.value.run_command_targets], [])

    content {
      key    = run_command_targets.value.key
      values = run_command_targets.value.values
    }
  }

  dynamic "ecs_target" {
    for_each = lookup(each.value, "ecs_target", null) != null ? [
      each.value.ecs_target
    ] : []

    content {
      group               = lookup(ecs_target.value, "group", null)
      launch_type         = lookup(ecs_target.value, "launch_type", null)
      platform_version    = lookup(ecs_target.value, "platform_version", null)
      task_count          = lookup(ecs_target.value, "task_count", null)
      task_definition_arn = lookup(ecs_target.value, "task_definition_arn", null)

      dynamic "network_configuration" {
        for_each = lookup(ecs_target.value, "network_configuration", null) != null ? [
          ecs_target.value.network_configuration
        ] : []

        content {
          subnets          = lookup(network_configuration.value, "subnets", null)
          security_groups  = lookup(network_configuration.value, "security_groups", null)
          assign_public_ip = lookup(network_configuration.value, "assign_public_ip", null)
        }
      }
    }
  }

  dynamic "batch_target" {
    for_each = lookup(each.value, "batch_target", null) != null ? [
      each.value.batch_target
    ] : []

    content {
      job_definition = batch_target.value.job_definition
      job_name       = batch_target.value.job_name
      array_size     = lookup(batch_target.value, "array_size", null)
      job_attempts   = lookup(batch_target.value, "job_attempts", null)
    }
  }
  dynamic "kinesis_target" {
    for_each = lookup(each.value, "kinesis_target", null) != null ? [true] : []

    content {
      partition_key_path = lookup(kinesis_target.value, "partition_key_path", null)
    }
  }

  dynamic "sqs_target" {
    for_each = lookup(each.value, "message_group_id", null) != null ? [true] : []

    content {
      message_group_id = each.value.message_group_id
    }
  }

  dynamic "http_target" {
    for_each = lookup(each.value, "http_target", null) != null ? [
      each.value.http_target
    ] : []

    content {
      path_parameter_values   = lookup(http_target.value, "path_parameter_values", null)
      query_string_parameters = lookup(http_target.value, "query_string_parameters", null)
      header_parameters       = lookup(http_target.value, "header_parameters", null)
    }
  }

  dynamic "input_transformer" {
    for_each = lookup(each.value, "input_transformer", null) != null ? [
      each.value.input_transformer
    ] : []

    content {
      input_paths    = input_transformer.value.input_paths
      input_template = input_transformer.value.input_template
    }
  }

  dynamic "dead_letter_config" {
    for_each = lookup(each.value, "dead_letter_arn", null) != null ? [true] : []

    content {
      arn = each.value.dead_letter_arn
    }
  }

  dynamic "retry_policy" {
    for_each = lookup(each.value, "retry_policy", null) != null ? [
      each.value.retry_policy
    ] : []

    content {
      maximum_event_age_in_seconds = retry_policy.value.maximum_event_age_in_seconds
      maximum_retry_attempts       = retry_policy.value.maximum_retry_attempts
    }
  }

  depends_on = [aws_cloudwatch_event_rule.this]
}


resource "aws_lambda_permission" "allow_events_bridge_to_run_lambda" {
    count = var.allow_events_bridge_to_run_lambda ? 1 : 0
    statement_id = var.statement_id
    action = "lambda:InvokeFunction"
    function_name = var.function_name
    principal = "events.amazonaws.com"
}

resource "aws_cloudwatch_event_bus" "this" {
  #count = var.create && var.create_bus ? 1 : 0
  count = var.create_bus ? 1 : 0

  name = var.bus_name
  tags = var.tags
}

resource "aws_cloudwatch_event_permission" "accounts" {
  for_each = var.principals
  event_bus_name = var.event_bus_name

  principal    = each.value
  statement_id = each.key
  depends_on = [aws_cloudwatch_event_bus.this]
}
