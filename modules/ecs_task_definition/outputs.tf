output "arn" {
  value = aws_ecs_task_definition.default.arn
}

output "family" {
  value = aws_ecs_task_definition.default.family
}


output "execution_role_arn" {
  value = aws_iam_role.execution_role.arn
}


output "task_role_arn" {
  value = aws_iam_role.task_role.arn
}
