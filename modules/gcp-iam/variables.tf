variable "project_id" {
  type = string
}

variable "organization_domain" {
  type    = string
  default = ""
}

variable "service_accounts" {
  type = map(object({
    sa_type            = string
    account_identifier = string
    description        = optional(string, null)
    disabled           = optional(bool, false)
    project            = optional(string, "")
    create_key         = optional(bool, false)
    key_rotation       = optional(bool, true)
    limit_length       = optional(number, 30)
    sa_roles           = optional(list(string), [])
    project_roles      = optional(map(list(string)), {})
    folder_roles       = optional(map(list(string)), {})
    bucket_roles       = optional(map(list(string)), {})
    organization_roles = optional(list(string), [])
    needs_context      = optional(bool, false)
    sa_iam_binding = optional(list(object({
      role    = optional(list(string), [])
      members = optional(list(string), [])
    })), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for sa in var.service_accounts :
      length(sa.organization_roles) > 0 ? var.organization_domain != "" : true
      ])
    error_message = "The 'organization_domain' variable must be set if any service account has 'organization_roles' defined."
  }

  validation {
    condition = alltrue([
      for sa in var.service_accounts :
      sa.sa_type == "external" ? sa.account_identifier != "" && sa.project != "" : true
      ])
    error_message = "The externally managed SA must have 'account_identifier' and 'project' defined."
  }

  validation {
    condition = alltrue([
      for sa in var.service_accounts :
      sa.sa_type == "gcp_managed" ? sa.account_identifier != "" : true
      ])
    error_message = "The gcp managed SA must have as account_identifier the email."
  }
}
