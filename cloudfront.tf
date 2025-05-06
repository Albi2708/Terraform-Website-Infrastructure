### --- OAC (origin access control) --- ###

# This resource creates an Origin Access Control (OAC) for private S3 access
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "cloud-programming-project-oac"
  description                       = "OAC for the Cloud Programming project s3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"   # sigV4 is the AWS signature version 4 protocol used to sign and authenticate requests to S3.
}



### --- Bucket policy to allow CloudFront OAC --- ###

data "aws_iam_policy_document" "allow_cf_oac" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static_site.arn}/*"]

    # Allows CloudFront to access the bucket
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

	# Ensures that only this specific CloudFront distribution (using its ARN) can access the bucket.
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cdn.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "allow_cf_oac" {
  bucket = aws_s3_bucket.static_site.id
  policy = data.aws_iam_policy_document.allow_cf_oac.json
}



### --- CloudFront distribution --- ###

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"

  # The 'origin' block specifies S3 as the backend using our new OAC
  origin {
    domain_name              = aws_s3_bucket.static_site.bucket_regional_domain_name
    origin_id                = "s3-origin"
	origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  # Default cache behavior for the static site, ensuring HTTPS and minimal config
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  # Use the default CloudFront certificate for HTTPS (no custom domain)
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # No geographic restrictions, open to all regions.
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}