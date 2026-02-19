resource "aws_vpc" "cell_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "vpc-cell-${var.availability_zone}" }
}

resource "aws_subnet" "cell_subnet" {
  vpc_id            = aws_vpc.cell_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.availability_zone
}

resource "aws_eks_cluster" "cell" {
  name     = "eks-cell-${var.availability_zone}"
  role_arn = "arn:aws:iam::123456789012:role/eks-role" 

  vpc_config {
    subnet_ids = [aws_subnet.cell_subnet.id]
  }
}

# Ajuste obrigatório para roteamento de borda e tolerância a falhas na CNI da AWS
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.cell.name
  addon_name   = "vpc-cni"

  configuration_values = jsonencode({
    env = {
      AWS_VPC_K8S_CNI_EXTERNALSNAT = "true"
    }
  })
}