output "cluster_name" { value = aws_eks_cluster.cell.name }
output "subnet_ids" { value = [aws_subnet.cell_subnet.id] }
output "internal_nlb_arn" { value = "arn:aws:elasticloadbalancing:..." }