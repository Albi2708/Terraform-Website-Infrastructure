### --- S3 bucket --- ###

resource "aws_s3_bucket" "static_site" {
  bucket        = "alberto-villa-9210857-s3-bucket"
  # force_destroy = true  # MEMO: easy cleanup during testing but remove for "production"
}


# Enable versioning and encryption for security purposes  

resource "aws_s3_bucket_versioning" "static_site_versioning" {
  bucket = aws_s3_bucket.static_site.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.static_site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


### --- S3 bucket object (index.html) --- ###

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.static_site.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html" 
}
