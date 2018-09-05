variable "iamName" {
  default = "UNDEF-NAME"
}

variable "iamEnvironment" {
  default = "UNDEF-ENV"
}

variable "iamPolicyResources" {
  type        = "list"
  default     = ["*"]
}

variable "iamRolePrincipals" {
  type        = "list"
}

variable "iamPolicyActions" {
  type        = "list"
  default     = ["*"]
}

variable "iamEnableCrossaccountRole" {
  default = false
}

variable "iamCrossAccountPrincipalARNs" {
  type        = "list"
  default     = ["00000000000","arn:aws:iam::XXXXXXXXXXXX:user/UNDEF_USER"]
}

variable "iamCrossAccountPolicyARNs" {
  description = "List of ARNs of policies to be associated with the created IAM role"
  type        = "list"
  default     = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser", "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
}


