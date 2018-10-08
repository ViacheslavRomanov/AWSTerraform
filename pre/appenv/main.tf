data "terraform_remote_state" "core" {
  backend = "s3"
  config {
    encrypt = true
    bucket = "aws-state-keeper"
    region = "us-east-1"
    key = "terraform/state.tfstate"
  }
}

output "app_elb" {
  value = "${data.terraform_remote_state.core.elbDNSName}"
}
