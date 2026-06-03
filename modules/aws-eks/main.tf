resource "aws_eks_cluster" "main" {
  name     = "Main"
  role_arn = aws_iam_role.eks_role.arn
  vpc_config {
    subnet_ids = data.aws_subnets.subnets.ids
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_default
  ]
}

data "aws_subnets" "subnets" {
  filter {
    name   = "tag:Name"
    values = ["Private*"]
  }
}

resource "aws_iam_role" "eks_role" {

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_default" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

