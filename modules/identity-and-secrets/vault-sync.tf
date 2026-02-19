resource "vault_secrets_sync_aws_destination" "aws_sm" {
  count                = local.is_aws? 1 : 0
  name                 = "aws-dest-${var.cluster_name}"
  secret_name_template = "vault_{{.MountAccessor | lowercase }}_{{.SecretPath | lowercase }}"
  region               = "us-east-1"
  role_arn             = aws_iam_role.pod_role.arn
}

resource "vault_secrets_sync_association" "aws_sync" {
  count            = local.is_aws? 1 : 0
  name             = "sync-aws-${var.cluster_name}"
  type             = "aws"
  mount            = var.vault_mount_path
  secret_name      = var.vault_secret_name
  destination_name = vault_secrets_sync_aws_destination.aws_sm.name
}

resource "vault_secrets_sync_azure_destination" "azure_kv" {
  count                = local.is_azure? 1 : 0
  name                 = "azure-dest-${var.cluster_name}"
  key_vault_uri        = var.azure_key_vault_uri
  secret_name_template = "vault-{{.MountAccessor }}-{{.SecretPath }}"
  client_id            = azurerm_user_assigned_identity.workload_identity.client_id
  tenant_id            = azurerm_user_assigned_identity.workload_identity.tenant_id
}

resource "vault_secrets_sync_association" "azure_sync" {
  count            = local.is_azure? 1 : 0
  name             = "sync-azure-${var.cluster_name}"
  type             = "azure"
  mount            = var.vault_mount_path
  secret_name      = var.vault_secret_name
  destination_name = vault_secrets_sync_azure_destination.azure_kv.name
}