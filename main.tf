terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.28.0"
    }
  }
}

provider "google" {
  # Configuration options
  project     = "i-ii-iii-academy"
  region      = "asia-east1"
  zone        = "asia-east1-a"
  credentials = "i-ii-iii-academy-edc04d80e0a0.json"
}

# Storage bucket -----------------------------------
resource "google_storage_bucket" "academy1" {
  name          = "bronzeplatiunum"
  location      = "ASIA"
  force_destroy = true

  uniform_bucket_level_access = false

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  cors {
    origin          = ["http://image-store.com"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

# Set bucket to ACL publicread -----------------------
# ACL = Access Control List = access control is the concept of limiting 
# or regulating a person or machine's access to certain information or resources
# PublicRead = allUsers can read the bucket

# https://www.freecodecamp.org/news/a-deep-dive-into-access-control-lists/

resource "google_storage_bucket_acl" "bucket_acl" {
  bucket         = google_storage_bucket.academy1.name
  predefined_acl = "publicRead"
}

// Uploading and setting public read access for HTML files
resource "google_storage_bucket_object" "upload_html" {
  for_each     = fileset("${path.module}/", "*.html")
  bucket       = google_storage_bucket.academy1.name
  name         = each.value
  source       = "${path.module}/${each.value}"
  content_type = "text/html"
}

// Public ACL for each HTML file
resource "google_storage_object_acl" "html_acl" {
  for_each       = google_storage_bucket_object.upload_html
  bucket         = google_storage_bucket_object.upload_html[each.key].bucket
  object         = google_storage_bucket_object.upload_html[each.key].name
  predefined_acl = "publicRead"
}

// Uploading and setting public read access for image files
resource "google_storage_bucket_object" "upload_images" {
  for_each     = fileset("${path.module}/", "*.jpg")
  bucket       = google_storage_bucket.academy1.name
  name         = each.value
  source       = "${path.module}/${each.value}"
  content_type = "image/jpeg"
}

// Public ACL for each image file
resource "google_storage_object_acl" "image_acl" {
  for_each       = google_storage_bucket_object.upload_images
  bucket         = google_storage_bucket_object.upload_images[each.key].bucket
  object         = google_storage_bucket_object.upload_images[each.key].name
  predefined_acl = "publicRead"
}

output "website_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.academy1.name}/index.html"
}

# Create an auto VPC with one subnet

# resource "google_compute_network" "auto-vpc-tf" {
#   name                    = "auto-vpc-tf"
#   auto_create_subnetworks = false
# }

# resource "google_compute_subnetwork" "sub-useast" {
#   name          = "sub-useast"
#   network       = google_compute_network.auto-vpc-tf.id
#   ip_cidr_range = "10.177.10.0/24"
#   region        = "us-east1"
# }


#resource "google_compute_network" "custom-vpc-tf" {
#name = "custom-vpc-tf"
#auto_create_subnetworks = false
#}

# output "auto" {
#   value = google_compute_network.auto-vpc-tf.id
# }

#output "custom" {
#  value = google_compute_network.custom-vpc-tf.id
#}
