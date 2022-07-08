provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Application = "cloud-resume"
    }
  }
}

locals {
  mime_types = {
    htm  = "text/html"
    html = "text/html"
    css  = "text/css"
    js   = "application/javascript"
    map  = "application/javascript"
    json = "application/json"
    jpg  = "image/jpg"
  }
}

resource "aws_s3_bucket" "resume-bucket" {
  bucket_prefix = "resume-bucket"
}

resource "aws_s3_bucket_acl" "resume-bucket-acl" {
  bucket = aws_s3_bucket.resume-bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "resume-web-config" {
  bucket = aws_s3_bucket.resume-bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}

resource "aws_s3_bucket_object" "resume-upload" {
  bucket   = aws_s3_bucket.resume-bucket.id
  for_each = fileset("../resume-site/", "**/*")

  key          = each.value
  source       = "../resume-site/${each.value}"
  etag         = filemd5("../resume-site/${each.value}")
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
}

resource "aws_s3_bucket_policy" "cv-bucket-policy" {
  bucket = aws_s3_bucket.resume-bucket.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "ResumeBucketPolicy",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
          "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::${aws_s3_bucket.resume-bucket.id}/*"
    }
  ]
}
POLICY
}