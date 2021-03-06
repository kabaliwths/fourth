resource "aws_iam_role" "ecs-service-role" {
    name                = "ecs-service-role"
    path                = "/"
    assume_role_policy  = "${data.aws_iam_policy_document.ecs-service-policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecs-service-role-attachment" {
    role       = "${aws_iam_role.ecs-service-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "ecs-service-policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ecs.amazonaws.com"]
        }
    }
}


data "aws_iam_policy_document" "s3_data_bucket_policy" {
  statement {
    sid = ""
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.fourthline_test.bucket}"
    ]
  }
  statement {
    sid = ""
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.fourthline_test.bucket}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_policy" {
  name   = "nginx-s3-policy"
  policy = "${data.aws_iam_policy_document.s3_data_bucket_policy.json}"
}


# Attaches a managed IAM policy to an IAM role
resource "aws_iam_role_policy_attachment" "ecs_role_s3_data_bucket_policy_attach" {
  role       = "${aws_iam_role.ecs-service-role.name}"
  policy_arn = "${aws_iam_policy.s3_policy.arn}"
}