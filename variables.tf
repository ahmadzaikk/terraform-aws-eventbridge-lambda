variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}
variable "allow_events_bridge_to_run_lambda" {
  default     = true
  description = "Set to `false` to prevent the module from creating any resources"
  type        = bool
}
variable "create_bus" {
  default     = false
  description = "Set to `false` to prevent the module from creating any resources"
  type        = bool
}
variable "bus_name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "statement_id" {
  type        = string
  default     = ""
  description = "Name  (statement_id)."
}
variable "tags" {
  type        = map(any)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "principals" {
  description = "(Required) list of AWS Accounts"
  type        = map(string)
  default     = {
    "chs-dev"  = "944706592399"
  }
}

variable "description" {
  type        = string
  default     = "Event rule to invoke lambda"
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "schedule_expression" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}
variable "event_pattern" {
  type        = string
  default     = ""
  description = "Name  (event_pattern`)."
}

variable "arn" {
  type        = string
  default     = "lambda arn"
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "function_name" {
  type        = string
  default     = "lambda fun name"
  description = "Name  (e.g. `app` or `cluster`)."
}
