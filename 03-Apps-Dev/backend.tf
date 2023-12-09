terraform {
  backend "s3" {
    bucket = "terraform.infrastructure.main.juried.com"
    key    = "03-Apps-Dev/tf.state"
    region = "us-east-1"
  }
}
