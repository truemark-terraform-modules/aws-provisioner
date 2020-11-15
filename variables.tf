variable "name" {
  description = "Name of the IAM user to create"
}

variable "s3_bucket" {
  description = "Name of the terraform bucket holding terraform state information. Defaults to <account>-terraform."
  default = null
}

variable "s3_prefix" {
  description = "The path prefix inside the terraform S3 bucket to grant access."
}

variable "policy" {
  description = "The policy to create and apply to the IAM user."
  default = null
}

variable "policy_arns" {
  description = "Additional policies to attach to the IAM user."
  default = []
}

variable "path" {
  default = "/terraform/security/"
}
