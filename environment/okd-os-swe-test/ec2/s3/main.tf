
resource "aws_iam_role" "S3ReadOnlyAccess" {
  name = "S3ReadOnlyAccess" 
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Stagement": [
    {
      "Action": "sts:AssumeRole",
      "Pricipal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource 
     
