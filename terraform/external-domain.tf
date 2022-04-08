locals {
  domain_name = "snapshot.nodes.pokt.network"
}

resource "aws_api_gateway_base_path_mapping" "snapshotter_nodes_pokt" {
  api_id      = aws_api_gateway_rest_api.snapshots.id
  stage_name  = aws_api_gateway_stage.main.stage_name
  domain_name = aws_api_gateway_domain_name.snapshotter.domain_name
}

resource "aws_api_gateway_domain_name" "snapshotter" {
  domain_name              = local.domain_name
  regional_certificate_arn = aws_acm_certificate_validation.snapshotter.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_acm_certificate" "snapshotter" {
  domain_name       = local.domain_name
  validation_method = "DNS"
}

resource "aws_route53_record" "snapshotter" {
  name    = local.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.nodes_pokt.zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.snapshotter.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.snapshotter.regional_zone_id
  }
}

resource "aws_route53_record" "snapshotter_acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.snapshotter.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.nodes_pokt.zone_id
}

resource "aws_acm_certificate_validation" "snapshotter" {
  certificate_arn         = aws_acm_certificate.snapshotter.arn
  validation_record_fqdns = [for record in aws_route53_record.snapshotter_acm_validation : record.fqdn]
}
