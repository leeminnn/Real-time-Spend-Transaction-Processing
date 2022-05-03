
resource "aws_dynamodb_table" "itsag1t5_campaign_dynamodb" {
    name             = "itsag1t5_campaigns"
    hash_key         = "id"
    billing_mode   = "PROVISIONED"
    read_capacity  = 5
    write_capacity = 5
    attribute {
        name = "id"
        type = "S"
    }
}