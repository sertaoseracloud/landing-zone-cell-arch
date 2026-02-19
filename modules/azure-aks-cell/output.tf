output "cluster_name" { value = azurerm_kubernetes_cluster.cell_cluster.name }
output "resource_group_name" { value = azurerm_resource_group.cell_rg.name }
output "subnet_ids" { value = [azurerm_subnet.cell_subnet.id] }
output "oidc_issuer_url" { value = azurerm_kubernetes_cluster.cell_cluster.oidc_issuer_url }
output "internal_lb_ip" { value = "10.1.1.50" }