variable "name" {
  description = "Name of the IAM user to create"
  type = string
}

variable "create_user" {
  description = "True to create an IAM user"
  type = bool
  default = true
}

variable "create_role" {
  description = "True to create an IAM role"
  type = bool
  default = false
}

variable "s3_bucket" {
  description = "Name of the terraform bucket holding terraform state information. Defaults to <account>-terraform."
  default = null
  type = string
}

variable "s3_prefix" {
  description = "Optional path prefix inside the terraform S3 bucket to grant access to."
  default = null
  type = string
}

variable "policy" {
  description = "The policy to create and apply to the IAM user."
  default = null
  type = string
}

variable "policies" {
  description = "The policies to create and apply to the IAM user."
  default = []
  type = list(string)
}

variable "policy_arns" {
  description = "Additional policies to attach to the IAM user."
  default = []
  type = list(string)
}

variable "path" {
  default = "/terraform/security/"
  type = string
}
