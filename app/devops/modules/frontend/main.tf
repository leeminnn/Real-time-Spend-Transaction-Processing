data "aws_canonical_user_id" "current" {}

resource "aws_s3_bucket" "itsag1t5_frontend_asset_bucket" {
  bucket        = "itsag1t5-frontend-asset"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "itsag1t5_frontend_asset_bucket_acl" {
  bucket = aws_s3_bucket.itsag1t5_frontend_asset_bucket.id
  access_control_policy {
    grant {
      grantee {
        type = "Group"
        uri  = "http://acs.amazonaws.com/groups/global/AllUsers"
      }
      permission = "READ"
    }
    
    grant {
      grantee {
        id   = data.aws_canonical_user_id.current.id
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }

    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }
}
