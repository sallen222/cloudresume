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

resource "aws_cloudfront_origin_access_identity" "resume-OAI" {
}

resource "aws_s3_bucket" "resume-bucket" {
  bucket = var.domain_name
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

resource "aws_s3_bucket_policy" "resume-bucket-policy" {
  bucket = aws_s3_bucket.resume-bucket.id

  depends_on = [
    aws_cloudfront_origin_access_identity.resume-OAI
  ]

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"2",
      "Effect":"Allow",
      "Principal":{
        "AWS":"${aws_cloudfront_origin_access_identity.resume-OAI.iam_arn}"
      },
      "Action": "s3:GetObject",
      "Resource": "${aws_s3_bucket.resume-bucket.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_route53_record" "r53-record-a" {
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.resume_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.resume_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "r53-record-aaaa" {
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.resume_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.resume_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_cloudfront_distribution" "resume_distribution" {
  origin {
    domain_name = aws_s3_bucket.resume-bucket.bucket_domain_name
    #IDK if this local is right
    origin_id = aws_s3_bucket.resume-bucket.id

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.resume-OAI.id}"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = [ "sallen.me" ]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.resume-bucket.id

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.certificate_arn
    ssl_support_method  = "sni-only"
  }
} 