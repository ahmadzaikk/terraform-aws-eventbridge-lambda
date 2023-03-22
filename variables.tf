variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}
variable "bus_name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}
variable "tags" {
  type        = map(any)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "description" {
  type        = string
  default     = "Event rule to invoke lambda"
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "schedule_expression" {
  type        = string
  default     = "cron schedule"
  description = "Name  (e.g. `app` or `cluster`)."
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
