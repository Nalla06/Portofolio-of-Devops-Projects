resource "aws_cloudwatch_log_group" "django-log-group" {
  name              = "/ecs/django-app"
  retention_in_days = var.log_retention_in_days
}
resource "aws_cloudwatch_log_group" "nginx-log-group" {
  name              = "/ecs/nginx/logs"
  retention_in_days = 7
}
resource "aws_cloudwatch_log_stream" "nginx-log-stream" {
  name           = "nginx-log-stream"
  log_group_name = aws_cloudwatch_log_group.nginx-log-group.name
}