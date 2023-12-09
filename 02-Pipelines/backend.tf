terraform {
  backend "s3" {
    bucket = "terraform.infrastructure.main.juried.com"
    key    = "02-Pipelines/tf.state"
    region = "us-east-1"
  }
}
