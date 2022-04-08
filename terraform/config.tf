terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.4.0"
    }
  }

  cloud {
    organization = "pokt-foundation"

    workspaces {
      name = "pocket-snapshotter"
    }
  }
}

provider "aws" {
  region = "us-east-2"

  # TODO: move to environment variables
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key

  default_tags {
    tags = {
      Purpose      = "PocketNodeSnapshots"
      MainteinedBy = "terraform"
      SourceCode   = "https://github.com/pokt-foundation/pocket-snapshotter"
    }
  }
}
