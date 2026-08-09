data "aws_iam_role" "management" {
  name = "terraform-management-server"
}

data "aws_iam_policy_document" "terraform_execution_trust" {
  statement {
    sid    = "AllowManagementServer"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        data.aws_iam_role.management.arn
      ]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "terraform_execution" {
  name                 = "${var.project_name}-terraform-execution"
  description          = "Terraform execution role assumed by approved infrastructure runners."
  assume_role_policy   = data.aws_iam_policy_document.terraform_execution_trust.json
  max_session_duration = 3600

  tags = {
    Name    = "${var.project_name}-terraform-execution"
    Purpose = "TerraformExecution"
  }
}

data "aws_iam_policy_document" "management_assume_execution" {
  statement {
    sid    = "AssumeTerraformExecutionRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    resources = [
      aws_iam_role.terraform_execution.arn
    ]
  }
}

resource "aws_iam_role_policy" "management_assume_execution" {
  name   = "${var.project_name}-assume-execution"
  role   = data.aws_iam_role.management.name
  policy = data.aws_iam_policy_document.management_assume_execution.json
}

data "aws_iam_policy_document" "terraform_state_access" {
  statement {
    sid    = "ListStateBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.terraform_state.arn
    ]
  }

  statement {
    sid    = "ReadWriteState"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "terraform_state_access" {
  name   = "${var.project_name}-state-access"
  role   = aws_iam_role.terraform_execution.name
  policy = data.aws_iam_policy_document.terraform_state_access.json
}

data "aws_iam_policy_document" "terraform_state_kms_access" {
  statement {
    sid    = "UseTerraformStateKmsKey"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]

    resources = [
      aws_kms_key.terraform_state.arn
    ]
  }
}

resource "aws_iam_role_policy" "terraform_state_kms_access" {
  name   = "${var.project_name}-state-kms-access"
  role   = aws_iam_role.terraform_execution.name
  policy = data.aws_iam_policy_document.terraform_state_kms_access.json
}
