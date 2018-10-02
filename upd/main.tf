data "terraform_remote_state" "core" {
  backend = "s3"
  config {
    encrypt = true
    bucket = "aws-state-keeper"
    region = "us-east-1"
    key = "terraform/state.tfstate"
  }
}

resource "null_resource" "null0"{
  provisioner "local-exec" {
    command = <<EOT
    echo 'export TF_VAR_db_name=${data.terraform_remote_state.core.rdsDBName}'>my_env
    echo 'export TF_VAR_db_user=${data.terraform_remote_state.core.rdsDBUser}'>>my_env
    echo 'export TF_VAR_db_password=${data.terraform_remote_state.core.rdsDBPassword}'>>my_env
    echo 'export TF_VAR_aws_region=${data.terraform_remote_state.core.appRegion}'>>my_env
    EOT
  }
}
