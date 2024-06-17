###################################################
# Create a S3 bucket with CloudFront distribution #
###################################################

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "cdn_bucket" {
  bucket = "bucket.name"
  
  tags = {
    tag1 = "name-tag-01"
    tag2 = "name-tag-02"
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["Access-Control-Allow-Origin"]
  }
}

resource "aws_cloudfront_distribution" "cdn_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.cdn_bucket.bucket}.s3.amazonaws.com"
    origin_id   = "S3-${aws_s3_bucket.cdn_bucket.bucket}"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "http-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_read_timeout      = 30
      origin_keepalive_timeout = 5
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for S3 bucket"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.cdn_bucket.bucket}"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    tag1 = "name-tag-01"
    tag2 = "name-tag-02"
  }
}
