data "aws_eks_cluster" "this" {
  name = "dev-platform-cluster"
}

data "aws_eks_cluster_auth" "this" {
  name = data.aws_eks_cluster.this.name
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.this.certificate_authority[0].data
    )
    token = data.aws_eks_cluster_auth.this.token
  }
}

resource "helm_release" "kyverno" {
  name       = "kyverno"
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno"
  namespace  = "kyverno"
  version    = "3.2.4"   # pin version (important)

  create_namespace = true

  wait             = true
  atomic           = false        # critical on small clusters
  timeout          = 600          # 10 minutes
  disable_webhooks = false

  values = [
    file("${path.module}/kyverno-values.yaml")
  ]
}
