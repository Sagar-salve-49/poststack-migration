terraform {
  backend "s3" {
    bucket       = "poststack-migration-terraform-state-459640517515-ap-south-1"
    key          = "bootstrap/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}
