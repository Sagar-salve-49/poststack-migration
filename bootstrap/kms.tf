data "aws_iam_policy_document" "terraform_state_kms_key" {
  #checkov:skip=CKV_AWS_111:KMS key policies require broad key-management permissions for account-level key administration.
  #checkov:skip=CKV_AWS_356:KMS key policies use Resource "*" because the policy is attached directly to this KMS key.
  #checkov:skip=CKV_AWS_109:KMS key administration permissions are intentionally restricted to the AWS account root principal.

  statement {
    sid    = "EnableAccountRootPermissions"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "AllowTerraformExecutionRole"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        aws_iam_role.terraform_execution.arn
      ]
    }

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_kms_key" "terraform_state" {
  description             = "KMS key for Terraform state encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = data.aws_iam_policy_document.terraform_state_kms_key.json

  tags = {
    Name    = "${var.project_name}-terraform-state"
    Purpose = "TerraformStateEncryption"
  }
}

resource "aws_kms_alias" "terraform_state" {
  name          = "alias/${var.project_name}-terraform-state"
  target_key_id = aws_kms_key.terraform_state.key_id
}
