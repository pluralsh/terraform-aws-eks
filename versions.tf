terraform {
  required_version = ">= 0.12.9, != 0.13.0"

  required_providers {
    aws        = ">= 3.22.0"
    local      = ">= 1.4"
    null       = ">= 2.1"
    random     = ">= 2.1"
    kubernetes = ">= 1.11.1"
  }
}
