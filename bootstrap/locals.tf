data "aws_caller_identity" "current" {}

locals {
  terraform_state_bucket_name = lower(
    "${var.project_name}-terraform-state-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
  )
}
