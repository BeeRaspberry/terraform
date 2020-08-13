//", != 3.29.0" https://github.com/terraform-providers/terraform-provider-google/issues/6744 
provider "google" {
  version = "~>  3.23, != 3.29.0"
  project = var.project_id
}

provider "google-beta" {
  version = "~>  3.23, != 3.29.0"
}

terraform {
  required_providers {
    google-beta = "~> 3.23, != 3.29.0"
  }
}