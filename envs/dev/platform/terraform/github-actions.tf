#create OIDC identity provider for github action

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

#trust rereplationsship define in json

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:Akashoistec/supply-chain-secuity:*"
      ]
    }
  }
}

#create Iam roles with define trust policy

resource "aws_iam_role" "github_actions_ecr" {
  name = "dev-github-actions-ecr-push"

  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

#IAM least privillege policy a github action pusdh to ECR role

data "aws_iam_policy_document" "github_actions_ecr_push" {

  # Required for Docker login
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  # Push image layers and manifests
  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = [
      "arn:aws:ecr:ap-south-1:910321623036:repository/demo-app"
    ]
  }

  # Read-only metadata access (required by tooling)
  statement {
    effect = "Allow"
    actions = [
      "ecr:DescribeRepositories",
      "ecr:DescribeImages",
      "ecr:BatchGetImage"
    ]
    resources = [
      "arn:aws:ecr:ap-south-1:910321623036:repository/demo-app"
    ]
  }
}

#attach policy to role 

resource "aws_iam_role_policy" "github_actions_ecr_policy" {
  role   = aws_iam_role.github_actions_ecr.id
  policy = data.aws_iam_policy_document.github_actions_ecr_push.json
}
