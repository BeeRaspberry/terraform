terraform {
  backend "gcs" {
    bucket      = "beeweb-terraform-state"
    prefix      = "development"
    credentials = "github_credential.json"
  }
}
