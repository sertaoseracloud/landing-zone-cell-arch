resource "aws_apigatewayv2_api" "cell_api" {
  count         = local.is_aws? 1 : 0
  name          = "api-${var.cluster_name}"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_vpc_link" "eks_link" {
  count              = local.is_aws? 1 : 0
  name               = "vpclink-${var.cluster_name}"
  subnet_ids         = var.subnet_ids
  security_group_ids = # IDs omitidos 
}

resource "aws_apigatewayv2_integration" "eks_internal" {
  count              = local.is_aws? 1 : 0
  api_id             = aws_apigatewayv2_api.cell_api.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = var.internal_lb_arn
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.eks_link.id
}