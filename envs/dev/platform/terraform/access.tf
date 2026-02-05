# 1. The readonly role
resource "aws_iam_role" "eks_readonly" {
  name = "dev-eks-readonly"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::910321623036:user/akash-admin"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# 2. Minimal policy: only allow DescribeCluster
resource "aws_iam_policy" "eks_describe_only" {
  name = "dev-eks-describe-only"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = aws_eks_cluster.this.arn
      }
    ]
  })
}

# 3. Attach that policy to the role
resource "aws_iam_role_policy_attachment" "eks_readonly_describe" {
  role       = aws_iam_role.eks_readonly.name
  policy_arn = aws_iam_policy.eks_describe_only.arn
}

