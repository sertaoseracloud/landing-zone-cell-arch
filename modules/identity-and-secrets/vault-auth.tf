resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = "kubernetes-${var.cluster_name}"
}

resource "vault_kubernetes_auth_backend_config" "k8s_auth" {
  backend         = vault_auth_backend.kubernetes.path
  kubernetes_host = "https://kubernetes.default.svc"
}

resource "vault_kubernetes_auth_backend_role" "app_role" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "app-role-${var.cluster_name}"
  bound_service_account_names      = ["app-sa"]
  bound_service_account_namespaces = ["application-ns"]
  token_policies                   = ["app-secrets-policy"]
}