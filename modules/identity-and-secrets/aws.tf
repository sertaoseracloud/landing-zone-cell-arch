data "aws_iam_policy_document" "assume_role" {
  count = local.is_aws? 1 : 0
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
    actions =
  }
}

resource "aws_iam_role" "pod_role" {
  count              = local.is_aws? 1 : 0
  name               = "${var.cluster_name}-pod-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_eks_pod_identity_association" "app_identity" {
  count           = local.is_aws? 1 : 0
  cluster_name    = var.aws_eks_cluster_name
  namespace       = "application-ns"
  service_account = "app-sa"
  role_arn        = aws_iam_role.pod_role.arn
}