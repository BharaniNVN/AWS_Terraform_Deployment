terraform {
  cloud {
    organization = "aws-build-terraform"

    workspaces {
      name = "terraform-dev"
    }
  }
}