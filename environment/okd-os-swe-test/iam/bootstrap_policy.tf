resource "aws_iam_role" "bootstrap_role" {
  name = "openshift-bootstrap-role"
  
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

resource "aws_iam_instance_profile" "bootstrap-role" {
  name = "openshift-bootstrap-role"
  role = aws_iam_role.bootstrap_role.name
}

resource "aws_iam_role_policy" "openshift-bootstrap-policy" {
  name        = "bootstrap-policy"
  role        = aws_iam_role.bootstrap_role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
         "Action": "ec2:Describe*",
         "Resource": "*",
         "Effect": "Allow"
      },
      {
         "Action": "ec2:AttachVolume",
         "Resource": "*",
         "Effect": "Allow"
      }, 
      {
         "Action": "ec2:DetatchVolume",
         "Resource": "*",
         "Effect": "Allow"
      },
      {
         "Action": "s3:GetObject",
         "Resource": "*",
         "Effect": "Allow"
      }
   ]
}
EOF
}
