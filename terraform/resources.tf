
# /latest.tar
resource "aws_api_gateway_resource" "latest_tar" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  parent_id   = aws_api_gateway_rest_api.snapshots.root_resource_id
  path_part   = "latest.tar"
}

resource "aws_api_gateway_method" "latest_tar" {
  rest_api_id   = aws_api_gateway_rest_api.snapshots.id
  resource_id   = aws_api_gateway_resource.latest_tar.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "latest_tar" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  resource_id = aws_api_gateway_method.latest_tar.resource_id
  http_method = aws_api_gateway_method.latest_tar.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
   "statusCode": 302
}
EOF
  }
}

resource "aws_api_gateway_method_response" "latest_tar_302" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  resource_id = aws_api_gateway_method.latest_tar.resource_id
  http_method = aws_api_gateway_method.latest_tar.http_method
  status_code = "302"

  response_parameters = { "method.response.header.location" = true }
}

resource "aws_api_gateway_integration_response" "latest_tar_302" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  resource_id = aws_api_gateway_method.latest_tar.resource_id
  http_method = aws_api_gateway_method.latest_tar.http_method
  status_code = aws_api_gateway_method_response.latest_tar_302.status_code

  response_parameters = { "method.response.header.location" = "'https://pokt.network'" }

  response_templates = {
    "text/plain" = "Provisioned with terraform, this response should be replaced with the script."
  }

  lifecycle {
    # We don't want terraform to change the value back just because the script has changed the response - meaning TF state is not in sync with AWS.
    ignore_changes = [
      response_parameters,
      response_templates
    ]
  }
}

# /latest.tar/md5
resource "aws_api_gateway_resource" "latest_tar_md5" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  parent_id   = aws_api_gateway_resource.latest_tar.id
  path_part   = "md5"
}

resource "aws_api_gateway_method" "latest_tar_md5" {
  rest_api_id   = aws_api_gateway_rest_api.snapshots.id
  resource_id   = aws_api_gateway_resource.latest_tar_md5.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "latest_tar_md5" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  resource_id = aws_api_gateway_method.latest_tar_md5.resource_id
  http_method = aws_api_gateway_method.latest_tar_md5.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
   "statusCode": 200
}
EOF
  }
}


resource "aws_api_gateway_method_response" "latest_tar_md5_200" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  resource_id = aws_api_gateway_method.latest_tar_md5.resource_id
  http_method = aws_api_gateway_method.latest_tar_md5.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "latest_tar_md5_200" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  resource_id = aws_api_gateway_method.latest_tar_md5.resource_id
  http_method = aws_api_gateway_method.latest_tar_md5.http_method
  status_code = aws_api_gateway_method_response.latest_tar_md5_200.status_code


  response_templates = {
    "text/plain" = "Provisioned with terraform, this response should be replaced with the script."
  }

  lifecycle {
    # We don't want terraform to change the value back just because the script has changed the response - meaning TF state is not in sync with AWS.
    ignore_changes = [
      response_templates
    ]
  }
}

# /latest.tar/sha1
resource "aws_api_gateway_resource" "latest_tar_sha1" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  parent_id   = aws_api_gateway_resource.latest_tar.id
  path_part   = "sha1"
}

resource "aws_api_gateway_method" "latest_tar_sha1" {
  rest_api_id   = aws_api_gateway_rest_api.snapshots.id
  resource_id   = aws_api_gateway_resource.latest_tar_sha1.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "latest_tar_sha1" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  resource_id = aws_api_gateway_method.latest_tar_sha1.resource_id
  http_method = aws_api_gateway_method.latest_tar_sha1.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
   "statusCode": 200
}
EOF
  }
}


resource "aws_api_gateway_method_response" "latest_tar_sha1_200" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  resource_id = aws_api_gateway_method.latest_tar_sha1.resource_id
  http_method = aws_api_gateway_method.latest_tar_sha1.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "latest_tar_sha1_200" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  resource_id = aws_api_gateway_method.latest_tar_sha1.resource_id
  http_method = aws_api_gateway_method.latest_tar_sha1.http_method
  status_code = aws_api_gateway_method_response.latest_tar_sha1_200.status_code


  response_templates = {
    "text/plain" = "Provisioned with terraform, this response should be replaced with the script."
  }

  lifecycle {
    # We don't want terraform to change the value back just because the script has changed the response - meaning TF state is not in sync with AWS.
    ignore_changes = [
      response_templates
    ]
  }
}


# /latest.tar.gz
resource "aws_api_gateway_resource" "latest_tar_gz" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  parent_id   = aws_api_gateway_rest_api.snapshots.root_resource_id
  path_part   = "latest.tar.gz"
}


resource "aws_api_gateway_method" "latest_tar_gz" {
  rest_api_id   = aws_api_gateway_rest_api.snapshots.id
  resource_id   = aws_api_gateway_resource.latest_tar_gz.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "latest_tar_gz" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  resource_id = aws_api_gateway_method.latest_tar_gz.resource_id
  http_method = aws_api_gateway_method.latest_tar_gz.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
   "statusCode": 302
}
EOF
  }
}


resource "aws_api_gateway_method_response" "latest_tar_gz_302" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  resource_id = aws_api_gateway_method.latest_tar_gz.resource_id
  http_method = aws_api_gateway_method.latest_tar_gz.http_method
  status_code = "302"

  response_parameters = { "method.response.header.location" = true }
}

resource "aws_api_gateway_integration_response" "latest_tar_gz_302" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  resource_id = aws_api_gateway_method.latest_tar_gz.resource_id
  http_method = aws_api_gateway_method.latest_tar_gz.http_method
  status_code = aws_api_gateway_method_response.latest_tar_gz_302.status_code

  response_parameters = { "method.response.header.location" = "'https://pokt.network'" }

  response_templates = {
    "text/plain" = "Provisioned with terraform, this response should be replaced with the script."
  }

  lifecycle {
    # We don't want terraform to change the value back just because the script has changed the response - meaning TF state is not in sync with AWS.
    ignore_changes = [
      response_parameters,
      response_templates
    ]
  }
}

# /latest.tar.gz/md5
resource "aws_api_gateway_resource" "latest_tar_gz_md5" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  parent_id   = aws_api_gateway_resource.latest_tar_gz.id
  path_part   = "md5"
}

resource "aws_api_gateway_method" "latest_tar_gz_md5" {
  rest_api_id   = aws_api_gateway_rest_api.snapshots.id
  resource_id   = aws_api_gateway_resource.latest_tar_gz_md5.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "latest_tar_gz_md5" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  resource_id = aws_api_gateway_method.latest_tar_gz_md5.resource_id
  http_method = aws_api_gateway_method.latest_tar_gz_md5.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
   "statusCode": 200
}
EOF
  }
}


resource "aws_api_gateway_method_response" "latest_tar_gz_md5_200" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  resource_id = aws_api_gateway_method.latest_tar_gz_md5.resource_id
  http_method = aws_api_gateway_method.latest_tar_gz_md5.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "latest_tar_gz_md5_200" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  resource_id = aws_api_gateway_method.latest_tar_gz_md5.resource_id
  http_method = aws_api_gateway_method.latest_tar_gz_md5.http_method
  status_code = aws_api_gateway_method_response.latest_tar_gz_md5_200.status_code


  response_templates = {
    "text/plain" = "Provisioned with terraform, this response should be replaced with the script."
  }

  lifecycle {
    # We don't want terraform to change the value back just because the script has changed the response - meaning TF state is not in sync with AWS.
    ignore_changes = [
      response_templates
    ]
  }
}

# /latest.tar.gz/sha1
resource "aws_api_gateway_resource" "latest_tar_gz_sha1" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  parent_id   = aws_api_gateway_resource.latest_tar_gz.id
  path_part   = "sha1"
}

resource "aws_api_gateway_method" "latest_tar_gz_sha1" {
  rest_api_id   = aws_api_gateway_rest_api.snapshots.id
  resource_id   = aws_api_gateway_resource.latest_tar_gz_sha1.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "latest_tar_gz_sha1" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  resource_id = aws_api_gateway_method.latest_tar_gz_sha1.resource_id
  http_method = aws_api_gateway_method.latest_tar_gz_sha1.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
   "statusCode": 200
}
EOF
  }
}


resource "aws_api_gateway_method_response" "latest_tar_gz_sha1_200" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  resource_id = aws_api_gateway_method.latest_tar_gz_sha1.resource_id
  http_method = aws_api_gateway_method.latest_tar_gz_sha1.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "latest_tar_gz_sha1_200" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id
  resource_id = aws_api_gateway_method.latest_tar_gz_sha1.resource_id
  http_method = aws_api_gateway_method.latest_tar_gz_sha1.http_method
  status_code = aws_api_gateway_method_response.latest_tar_gz_sha1_200.status_code


  response_templates = {
    "text/plain" = "Provisioned with terraform, this response should be replaced with the script."
  }

  lifecycle {
    # We don't want terraform to change the value back just because the script has changed the response - meaning TF state is not in sync with AWS.
    ignore_changes = [
      response_templates
    ]
  }
}
