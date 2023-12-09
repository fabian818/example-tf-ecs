output "dns_name" {
  value = aws_lb.default.dns_name
}

output "id" {
  value = aws_lb.default.id
}

output "arn" {
  value = aws_lb.default.arn
}

output "http_listener_arn" {
  value = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  value = aws_lb_listener.https.arn
}
