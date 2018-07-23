#================================================================
# Module Calling - Services for Remote State
#================================================================

module "aws_s3_state_dev" {
  source = "git::https://github.com/mynoton/projectone-module.git//modules/aws_s3_state?ref=v0.0.4"
  s3_bucket_name = "projectone-state-dev"
  s3_versioning = true
}

module "aws_dynamodb_state_lock_dev" {
  source = "git::https://github.com/mynoton/projectone-module.git//modules/aws_dynamodb?ref=v0.0.4"
  dynamodb_tbl_name = "projectone-state-lock-dev"
  dynamodb_read_capacity = 1
  dynamodb_write_capacity = 1
  dynamodb_hash_key = "LockID"
  dynamodb_attribute_name = "LockID"
  dynamodb_attribute_type = "S"
}
