provider "aws" {
  access_key = "your-access-key"          # Hardcoded AWS credentials
  secret_key = "your-secret-key"          # Hardcoded AWS credentials
  region     = "us-east-1"
}

resource "aws_s3_bucket" "insecure_bucket" {
  bucket = "vulnerable-bucket"
  acl    = "public-read"                 # Publicly accessible S3 bucket

  logging {
    target_bucket = "logging-bucket"     # Non-existent logging bucket
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_security_group" "insecure_sg" {
  name = "insecure-sg"
  description = "Insecure Security Group"

  ingress {
    from_port   = 0 
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]          
  }

  egress {
    from_port   = 0                  
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]      
  }
}

resource "aws_db_instance" "insecure_db" {
  identifier              = "insecure-db"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "5.6"
  instance_class          = "db.t2.micro"
  username                = "admin"
  password                = "InsecurePassword"  
  publicly_accessible     = true                
  skip_final_snapshot     = true                
}

resource "aws_iam_policy" "insecure_policy" {
  name        = "insecure-policy"
  description = "Overly permissive IAM policy"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "insecure_role" {
  name               = "insecure-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "insecure_policy_attachment" {
  role       = aws_iam_role.insecure_role.name
  policy_arn = aws_iam_policy.insecure_policy.arn
}

resource "aws_instance" "insecure_instance" {
  ami           = "ami-0c55b159cbfafe1f0"      
  instance_type = "t2.micro"
  key_name      = "insecure-key"              

  security_groups = [
    aws_security_group.insecure_sg.name
  ]

  user_data = <<EOF
#!/bin/bash
echo "This is an insecure instance" > /var/tmp/insecure.txt
EOF
}
