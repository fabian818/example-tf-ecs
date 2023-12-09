output "ecr_repos" {
  value = {
    for k, obj in module.ecr_repos : k => {
      arn            = obj.arn
      repository_url = obj.repository_url
    }
  }
}

output "s3_buckets" {
  value = {
    for k, obj in module.buckets : k => {
      id                 = obj.id
      arn                = obj.arn
      bucket_domain_name = obj.bucket_domain_name
    }
  }
}