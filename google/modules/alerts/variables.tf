variable "notification_list" {
  type           = list(object({
    display_name = string
    email        = string
  }))
  default        = [
    {
      display_name = "Bart"
      email        = "bart@springfield.com"
    },
    {
      display_name = "Lisa"
      email        = "lisa@springfield.com"
    },
    {
      display_name = "Marge"
      email        = "marge@springfield.com"
    }
  ]
}
