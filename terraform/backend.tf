terraform {
  backend "s3" {
    bucket = "todo-state"
    key    = "todo-app"
    region = "us-east-1"
  }
}
