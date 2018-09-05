resource "aws_iam_policy_attachment" "iam_policy_attachment" {
  name        = "${lower(var.iamName)}-iam_policy_attachment-${lower(var.iamEnvironment)}"
  roles       = ["${aws_iam_role.iam_role.name}"]
  policy_arn  = "${aws_iam_policy.iam_policy.arn}"
}


resource "aws_iam_role_policy_attachment" "cross_account_assume_role" {
  count      = "${var.iamEnableCrossaccountRole ? length(var.iamCrossAccountPolicyARNs) : 0}"

  role       = "${aws_iam_role.cross_account_assume_role.name}"
  policy_arn = "${element(var.iamCrossAccountPolicyARNs, count.index)}"

  depends_on = ["aws_iam_role.cross_account_assume_role"]
}

resource "aws_iam_role" "cross_account_assume_role" {
  count              = "${var.iamEnableCrossaccountRole ? 1 : 0}"

  name               = "${lower(var.iamName)}-cross_account_assume_role-${lower(var.iamEnvironment)}"
  description        = "IAN ${var.iamName}-cross_account_assume_role-${var.iamEnvironment} role"
  assume_role_policy = "${data.aws_iam_policy_document.cross_account_assume_role_policy.json}"
}

data "aws_iam_policy_document" "cross_account_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["${var.iamCrossAccountPrincipalARNs}"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "policy-document" {
  "statement" {
    effect = "Allow"

    resources = [
      "${var.iamPolicyResources}",
    ]

    actions = [
      "${var.iamPolicyActions}",
    ]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name        = "${lower(var.iamName)}-iam_policy-${lower(var.iamEnvironment)}"
  description = "IAM ${var.iamName}-policy-${var.iamEnvironment} policy"
  policy      = "${data.aws_iam_policy_document.policy-document.json}"
}

data "aws_iam_policy_document" "role-policy-document" {
  "statement" {
    effect = "Allow"
    principals {
      identifiers = [
        "${var.iamRolePrincipals}",
      ]
      type = "Service"
    }
    actions = [
      "sts:AssumeRole",
    ]
  }
}
resource "aws_iam_role" "iam_role" {
  name = "${lower(var.iamName)}-iam_role-${lower(var.iamEnvironment)}"
  description = "${var.iamName}-role-${var.iamEnvironment} role"
  path = "/"
  assume_role_policy = "${data.aws_iam_policy_document.role-policy-document.json}"
}

# IAM Instance profile
resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "${lower(var.iamName)}-iam_instance_profile-${lower(var.iamEnvironment)}"
  role = "${aws_iam_role.iam_role.name}"
  depends_on = ["aws_iam_role.iam_role"]
}