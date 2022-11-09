resource "aws_s3_bucket" "bucket" {
  bucket = var.s3_bucket_name

  /*
  tags = {
    Name        = "My bucket"
    Environment = "dev"
  }
  */
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}