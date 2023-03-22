resource "aws_cloudwatch_event_rule" "schedule" {
    name = var.name
    event_bus_name = aws_cloudwatch_event_bus.this.*.name
    description = var.description
    schedule_expression = var.schedule_expression
    depends_on = [aws_cloudwatch_event_bus.this]
    event_pattern = var.event_pattern
}

resource "aws_cloudwatch_event_target" "schedule_lambda" {
    rule = aws_cloudwatch_event_rule.schedule.name
    event_bus_name = aws_cloudwatch_event_bus.this.*.name
    target_id = "processing_lambda"
    arn = var.arn
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
  event_bus_name = aws_cloudwatch_event_bus.this.*.name

  principal    = each.value
  statement_id = each.key
  depends_on = [aws_cloudwatch_event_bus.this]
}
