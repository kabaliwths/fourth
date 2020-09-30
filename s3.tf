resource "aws_s3_bucket" "fourthline_test" {
  bucket = "fourthline-test"
  acl    = "private"
}