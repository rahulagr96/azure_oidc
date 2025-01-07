# Variable for App Registration owners
variable "app_registration_owners" {
  type        = list(string)
  description = "List of App Registration owners"
  default = [
    "9fe72cd3-cf73-4bd4-8d9d-0d826fe32d79" # Rahul
  ]
}

# Variable for Azure Subscription ID
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}