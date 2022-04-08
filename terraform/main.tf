resource "aws_api_gateway_rest_api" "snapshots" {
  name = "pokt-snapshots"
}

resource "aws_api_gateway_deployment" "snapshots" {
  rest_api_id = aws_api_gateway_rest_api.snapshots.id

  # We are not going to trigger the deployment from terraform - the script does that after the snapshot update.
  #   triggers = {
  #     # NOTE: The configuration below will satisfy ordering considerations,
  #     #       but not pick up all future REST API changes. More advanced patterns
  #     #       are possible, such as using the filesha1() function against the
  #     #       Terraform configuration file(s) or removing the .id references to
  #     #       calculate a hash against whole resources. Be aware that using whole
  #     #       resources will show a difference after the initial implementation.
  #     #       It will stabilize to only change when resources change afterwards.
  #     redeployment = sha1(jsonencode([
  #       aws_api_gateway_integration_response.latest_tar_302.id,
  #       aws_api_gateway_integration_response.latest_tar_md5_200.id,
  #       aws_api_gateway_integration_response.latest_tar_sha1_200.id,
  #       aws_api_gateway_integration_response.latest_tar_gz_302.id,
  #       aws_api_gateway_integration_response.latest_tar_gz_md5_200.id,
  #       aws_api_gateway_integration_response.latest_tar_gz_sha1_200.id,
  #     ]))
  #   }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.snapshots.id
  rest_api_id   = aws_api_gateway_rest_api.snapshots.id
  stage_name    = "main"

  depends_on = [aws_cloudwatch_log_group.snapshotter_main]

  lifecycle {
    # We don't want terraform to change the value back just because the script has changed the response - meaning TF state is not in sync with AWS.
    ignore_changes = [
      deployment_id
    ]
  }
}

resource "aws_cloudwatch_log_group" "snapshotter_main" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.snapshots.id}/main"
  retention_in_days = 30
}
