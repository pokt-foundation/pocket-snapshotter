# Since we're running this in non-aws environment, we need to generate the keys.

module "iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "~> 4"

  name = "pocket-snapshotter"

  create_iam_user_login_profile = false
  create_iam_access_key         = true
}

data "aws_iam_policy_document" "snapshotter_user_policy" {
  statement {
    actions   = ["apigateway:GET"]
    resources = ["${aws_api_gateway_rest_api.snapshots.arn}/resources"]
  }
}

module "snapshotter_user_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = "allow_api_gw_updates"
  path        = "/"
  description = "Allows interaction with API Gateway to update links and redirects"

  policy = data.aws_iam_policy_document.snapshotter_user_policy.json
}

resource "aws_iam_policy_attachment" "snapshotter_user" {
  name       = module.snapshotter_user_policy.name
  users      = [module.iam_user.iam_user_name]
  policy_arn = module.snapshotter_user_policy.arn
}
