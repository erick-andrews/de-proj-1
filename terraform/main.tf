provider "aws" {
  region = "us-east-1" # Change the region as needed
}

resource "aws_s3_bucket" "ip_explorer" {
  bucket = "ip-explorer" # S3 bucket name

  acl    = "private" # Change ACL if needed (e.g., "public-read")

  tags = {
    Name        = "ip_explorer"
    Environment = "Development"
  }
}

resource "aws_s3_bucket_object" "bronze_folder" {
  bucket = aws_s3_bucket.ip_explorer.id
  key    = "bronze/"
}

resource "aws_s3_bucket_object" "silver_folder" {
  bucket = aws_s3_bucket.ip_explorer.id
  key    = "silver/"
}

resource "aws_s3_bucket_object" "gold_folder" {
  bucket = aws_s3_bucket.ip_explorer.id
  key    = "gold/"
}
