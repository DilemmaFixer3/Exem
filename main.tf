terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
  backend "s3" {
    endpoint                    = "fra1.digitaloceanspaces.com"
    region                      = "us-east-1"
    bucket                      = "babiichuk-terraform-state" 
    key                         = "terraform.tfstate"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
}

provider "digitalocean" {}

resource "digitalocean_vpc" "babiichuk_vpc" {
  name     = "babiichuk-vpc"
  region   = "fra1"
  ip_range = "10.10.10.0/24"
}

resource "digitalocean_droplet" "babiichuk_node" {
  name     = "babiichuk-node"
  region   = "fra1"
  size     = "s-2vcpu-4gb"
  image    = "ubuntu-24-04-x64"
  vpc_uuid = digitalocean_vpc.babiichuk_vpc.id
}

resource "digitalocean_firewall" "babiichuk_firewall" {
  name        = "babiichuk-firewall"
  droplet_ids = [digitalocean_droplet.babiichuk_node.id]

  dynamic "inbound_rule" {
    for_each = [22, 80, 443, 8000, 8001, 8002, 8003]
    content {
      protocol         = "tcp"
      port_range       = inbound_rule.value
      source_addresses = ["0.0.0.0/0", "::/0"]
    }
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_spaces_bucket" "babiichuk_bucket" {
  name   = "babiichuk-bucket"
  region = "fra1"
}
