data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "devops-opendaoc_velero_policy" {
  name        = "devops-opendaoc-velero-policy"
  description = "Policy for Velero EC2 and S3 operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:DeleteObject",
          "s3:DeleteObjectAcl",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Resource = [
          "arn:aws:s3:::${local.bucket_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${local.bucket_name}"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "devops-opendaoc_velero_role" {
  name        = "devops-opendaoc-velero-role"
  description = "Role for Velero EC2 and S3 operations"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        },
        {
          "Effect" : "Allow",
          "Principal" : {
            "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.openid_connect_provider_uri}"
          },
          "Action" : "sts:AssumeRoleWithWebIdentity",
          "Condition" : {
            "StringEquals" : {
              "${local.openid_connect_provider_uri}:sub" : "system:serviceaccount:velero:velero-server"
            }
          }
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "devops-opendaoc_velero_policy_attachment" {
  role       = aws_iam_role.devops-opendaoc_velero_role.name
  policy_arn = aws_iam_policy.devops-opendaoc_velero_policy.arn
}