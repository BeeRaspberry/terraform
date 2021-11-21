//", != 3.29.0" https://github.com/terraform-providers/terraform-provider-google/issues/6744 
provider "google" {
  credentials = var.cred_file == "" ? var.credential : file(var.cred_file)
  version = "~>  3.23, != 3.29.0"
  project = var.project_id
}

provider "google-beta" {
  credentials = var.cred_file == "" ? var.credential : file(var.cred_file)
  version = "~>  3.23, != 3.29.0"
  project = var.project_id
}

terraform {
  required_providers {
    google-beta = "~> 3.23, != 3.29.0"
  }
}
