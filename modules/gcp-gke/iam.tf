resource "google_service_account" "primary" {
  account_id   = "gke-node-sa"
  display_name = "GKE Service Account"
}

resource "google_project_iam_member" "gke_sa_editor" {
  project = data.google_project.project.id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.primary.email}"
}