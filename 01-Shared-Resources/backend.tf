terraform {
  backend "s3" {
    bucket = "terraform.infrastructure.main.juried.com"
    key    = "01-Shared-Resources/tf.state"
    region = "us-east-1"
  }
}
