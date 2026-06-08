data "google_service_account" "external" {
  for_each = var.service_accounts != null ? {
    for k, v in var.service_accounts : k => v
    if v.sa_type == "external"
  } : {}

  account_id = each.value.account_identifier
  project    = each.value.project
}

data "google_organization" "org" {
  count  = var.organization_domain != "" ? 1 : 0
  domain = var.organization_domain
}


resource "google_service_account" "this" {
  for_each     = { for k, v in var.service_accounts : k => v if v.sa_type == "managed" }
  account_id   = substr(each.key, 0, each.value.limit_length)
  description  = each.value.description
  disabled     = each.value.disabled
  display_name = each.value.account_identifier != "" ? each.value.account_identifier : each.key
  project      = var.project_id
}

locals {
  all_service_accounts = merge(
    { for k, v in var.service_accounts : k => {
      email          = try(google_service_account.this[k].email, null)
      id             = try(google_service_account.this[k].id, null)
      name           = try(google_service_account.this[k].name, null)
      create_key     = v.create_key
      key_rotation   = v.key_rotation
      needs_context  = v.needs_context
      sa_roles       = v.sa_roles
      project_roles  = v.project_roles
      folder_roles   = v.folder_roles
      bucket_roles   = v.bucket_roles
      org_roles      = v.organization_roles
      sa_iam_binding = v.sa_iam_binding
    } if v.sa_type == "managed"
    },
    { for k, v in var.service_accounts : k => {
      email          = data.google_service_account.external[k].email
      id             = data.google_service_account.external[k].id
      name           = data.google_service_account.external[k].name
      create_key     = v.create_key
      key_rotation   = v.key_rotation
      needs_context  = v.needs_context
      sa_roles       = v.sa_roles
      project_roles  = v.project_roles
      folder_roles   = v.folder_roles
      bucket_roles   = v.bucket_roles
      org_roles      = v.organization_roles
      sa_iam_binding = v.sa_iam_binding
    } if v.sa_type == "external"
    },
    { for k, v in var.service_accounts : k => {
      email          = v.account_identifier
      sa_roles       = v.sa_roles
      create_key     = v.create_key
      key_rotation   = v.key_rotation
      needs_context  = v.needs_context
      project_roles  = v.project_roles
      folder_roles   = v.folder_roles
      bucket_roles   = v.bucket_roles
      org_roles      = v.organization_roles
      sa_iam_binding = v.sa_iam_binding
    } if v.sa_type == "google_managed"
    }
  )
}

locals {
  sa_roles = flatten([
    for sa_name, sa in local.all_service_accounts : [
      for role in sa.sa_roles : {
        id      = sa.id
        sa_name = sa_name
        email   = sa.email
        role    = role
      }
    ]
  ])
}

locals {
  project_roles = flatten([
    for sa_name, sa in local.all_service_accounts : [
      for project, roles in sa.project_roles : [
        for role in roles : {
          sa_name = sa_name
          email   = sa.email
          project = project
          role    = role
        }
      ]
    ]
  ])
}

locals {
  folder_roles = flatten([
    for sa_name, sa in local.all_service_accounts : [
      for folder, roles in sa.folder_roles : [
        for role in roles : {
          sa_name   = sa_name
          email     = sa.email
          folder_id = folder
          role      = role
        }
      ]
    ]
  ])
}

locals {
  bucket_roles = flatten([
    for sa_name, sa in local.all_service_accounts : [
      for bucket, roles in sa.bucket_roles : [
        for role in roles : {
          sa_name = sa_name
          email   = sa.email
          bucket  = bucket
          role    = role
        }
      ]
    ]
  ])
}

locals {
  org_roles = flatten([
    for sa_name, sa in local.all_service_accounts : [
      for role in sa.org_roles : {
        sa_name = sa_name
        email   = sa.email
        org     = data.google_organization.org[0].org_id
        role    = role
      }
    ]
  ])
}

locals {
  sa_iam_binding = flatten([
    for sa_name, sa in local.all_service_accounts : [
      for iam_binding in sa.sa_iam_binding : [
        for role in iam_binding.role : {
          sa_name = sa_name
          role    = role
          members = iam_binding.members
        }
      ]
    ]
  ])
}

resource "google_service_account_iam_member" "service_account_roles" {
  for_each = {
    for r in local.sa_roles :
    "${r.role}/serviceAccount:${r.email}" => r
  }

  service_account_id = local.all_service_accounts[each.value.sa_name].id
  role               = each.value.role
  member             = "serviceAccount:${local.all_service_accounts[each.value.sa_name].email}"
}

resource "google_project_iam_member" "project_roles" {
  for_each = {
    for r in local.project_roles :
    "${r.project}/${r.role}/serviceAccount:${r.email}" => r
  }

  project = each.value.project
  role    = each.value.role
  member  = "serviceAccount:${local.all_service_accounts[each.value.sa_name].email}"
}

resource "google_folder_iam_member" "folder_roles" {
  for_each = {
    for r in local.folder_roles :
    "${r.folder_id}/${r.role}/serviceAccount:${r.email}" => r
  }

  folder = each.value.folder_id
  role   = each.value.role
  member = "serviceAccount:${local.all_service_accounts[each.value.sa_name].email}"
}

resource "google_storage_bucket_iam_member" "bucket_roles" {
  for_each = {
    for r in local.bucket_roles :
    "${r.bucket}/${r.role}/serviceAccount:${r.email}" => r
  }

  bucket = each.value.bucket
  role   = each.value.role
  member = "serviceAccount:${local.all_service_accounts[each.value.sa_name].email}"
}

resource "google_organization_iam_member" "org_roles" {
  for_each = {
    for r in local.org_roles :
    "${r.org}/${r.role}/serviceAccount:${r.email}" => r
  }

  org_id = each.value.org
  role   = each.value.role
  member = "serviceAccount:${local.all_service_accounts[each.value.sa_name].email}"
}

resource "google_service_account_iam_binding" "service_account_iam_binding" {
  for_each = {
    for r in local.sa_iam_binding :
    "${r.role}/serviceAccount:${r.sa_name}/iam_binding" => r
  }
  service_account_id = local.all_service_accounts[each.value.sa_name].name
  role               = each.value.role
  members            = each.value.members
}

resource "time_rotating" "gcp_sa_key_rotation" {
  count         = contains([for sa in values(var.service_accounts) : sa.create_key], true) ? 1 : 0
  rotation_days = 6
}

resource "google_service_account_key" "sa_key" {
  for_each = {
    for sa_name, sa in local.all_service_accounts :
    sa_name => sa
    if sa.create_key
  }

  service_account_id = each.value.id
  public_key_type    = "TYPE_X509_PEM_FILE"

  lifecycle {
    create_before_destroy = true
  }

  keepers = {
    rotation_time = each.value.key_rotation ? time_rotating.gcp_sa_key_rotation[0].rotation_rfc3339 : null
  }
}