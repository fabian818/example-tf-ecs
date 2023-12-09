terraform {
  backend "s3" {
    bucket = "terraform.infrastructure.main.juried.com"
    key    = "05-Apps-Production/tf.state"
    region = "us-east-1"
  }
}
