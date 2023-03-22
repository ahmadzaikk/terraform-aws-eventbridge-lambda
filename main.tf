resource "aws_cloudwatch_event_rule" "schedule" {
    name = var.name
    description = var.description
    schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "schedule_lambda" {
    rule = aws_cloudwatch_event_rule.schedule.name
    target_id = "processing_lambda"
    arn = var.arn
}


resource "aws_lambda_permission" "allow_events_bridge_to_run_lambda" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = var.function_name
    principal = "events.amazonaws.com"
}

resource "aws_cloudwatch_event_bus" "this" {
  #count = var.create && var.create_bus ? 1 : 0

  name = var.bus_name
  tags = var.tags
}
