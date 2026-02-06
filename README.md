Platform Governance — Secure EKS Baseline

This repository defines a governed Kubernetes platform on Amazon EKS.

The platform applies controls at admission, separates identity across runtime, CI, and human access, and keeps sensitive actions auditable.
It represents a reference platform baseline, not an application.

What the Platform Covers

The platform defines a supported workload path.
Workloads that fall outside this path are filtered at admission.

Admission Controls (Kyverno)

Controls are applied before scheduling.

Tenancy

Workloads are not allowed in the default namespace

Only approved application namespaces are accepted

Supply Chain

Images are pulled only from Amazon ECR

Mutable tags (for example latest) are not accepted

Images are referenced by digest

Pod Security

Kubernetes PSA restricted is applied cluster-wide

Privileged containers and root execution are not allowed

Release Hygiene

CPU and memory requests and limits are required

Standard labels (app, env, owner) are expected on workloads

The result is a small, well-defined workload shape that the platform accepts.

Validation

The platform was exercised using a set of test workloads applied directly to the cluster.

Observed behavior:

workload in default namespace → filtered

non-ECR image → filtered

mutable tag → filtered

missing resources or labels → filtered

compliant workload → admitted

Test manifests are available under:

tests/workloads/


Screenshots captured during validation are under:

docs/screenshots/k8s/

Workload Identity (IRSA)

Application workloads use IRSA for AWS access.

Pods run with a dedicated Kubernetes ServiceAccount

AWS identity is assumed using OIDC

Credentials are short-lived and scoped to the workload

Actions outside the role scope return AccessDenied, which was verified during testing.

Evidence is available under:

docs/screenshots/aws/

CI/CD Identity (GitHub Actions OIDC)

CI workflows authenticate to AWS using GitHub Actions OIDC.

No static AWS credentials are stored in the repository

Each workflow assumes a dedicated IAM role

CI identity is separate from workload and human access

Terraform plans for the platform run using this identity.

Break-Glass Access and Audit

A dedicated break-glass role exists for recovery scenarios.

The role is not used during normal operation

Assumption is a manual action

Usage is visible through CloudTrail events

CloudTrail logs are retained in an encrypted S3 bucket, and alerts are generated when the break-glass role is assumed.

Infrastructure Scope

The platform includes:

VPC with private networking

EKS cluster and managed node groups

IAM roles for platform operations, CI/CD, workloads (IRSA), and break-glass access

Kyverno installed as a cluster add-on

Terraform code lives under:

envs/dev/platform/terraform/

Status

Platform validated against a live cluster

Evidence captured during validation

Cluster destroyed after validation
