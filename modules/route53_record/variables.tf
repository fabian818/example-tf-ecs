variable "zone_id" {
  type    = string
  default = "Zone ID for the route53 record"
}

variable "dns" {
  type        = string
  description = "Domain name for the route53 record"
}

variable "type" {
  type        = string
  description = "Record type"
}

variable "ttl" {
  type        = number
  description = "TTL for the route53 record"
}

variable "records" {
  type        = list(string)
  description = "Target value for the record"
}
