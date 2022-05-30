terraform {
  required_version = ">= 0.14.0"

  required_providers {
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = ">= 0.14.2"
    }
    htpasswd = {
      source  = "loafoe/htpasswd"
      version = ">= 1.0.2"
    }
    random = {
      source  = "random"
      version = ">= 2.2.1"
    }
  }
}
