resource "aws_iam_role" "worker_role" {
  name = "openshift-worker-role"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "worker-role" {
  name = "openshift-worker-role"
  role = aws_iam_role.worker_role.name
}

resource "aws_iam_role_policy" "worker_policy" {
  name = "openshift-worker-policy"
  role = aws_iam_role.worker_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DecribeInstances",
        "ec2:DescribeRegions"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}
