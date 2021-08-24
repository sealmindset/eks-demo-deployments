data "aws_eks_cluster" "cluster" {
  name = module.cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "cluster" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.1.0"
  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  worker_groups = [
    {
      instance_type        = var.wg_instance_type
      asg_max_size         = var.wg_asg_max_size
      asg_desired_capacity = var.wg_asg_desired_capacity
    }
  ]

  write_kubeconfig = var.write_kubeconfig
}
