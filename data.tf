data "aws_elb_service_account" "current" {}

data "aws_vpc" "shared" {
  id = "vpc-123456789"
}

// Définir les filtres communs pour les sous-réseaux
locals {
  subnet_filters = [
    {
      name   = "vpc-id"
      values = [data.aws_vpc.shared.id]
    },
    {
      name   = "cidr-block"
      values = [data.aws_vpc.shared.cidr_block]
    },
  ]
}

// Générer les données des sous-réseaux en utilisant une boucle
data "aws_subnet" "private_networking" {
  count = 3  // Nombre de sous-réseaux à créer

  filter {
    // Utiliser les filtres communs
    name   = local.subnet_filters[count.index].name
    values = local.subnet_filters[count.index].values
  }

  filter {
    name   = "cidr-block"
    values = [cidrsubnet(data.aws_vpc.shared.cidr_block, 8, count.index)]
  }
}

// Récupérer les zones Route 53
data "aws_route53_zone" "gitlab" {
  name = var.gitlab_hosted_zone_name
}

data "aws_route53_zone" "vpn" {
  name = var.vpn_hosted_zone_name
}

data "aws_route53_zone" "shared" {
  name = var.shared_hosted_zone_name
}
