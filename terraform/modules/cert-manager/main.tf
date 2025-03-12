module "cert_manager" {
  source        = "terraform-iaac/cert-manager/kubernetes"

  create_namespace                        = true
  namespace_name                          = var.cert_manager_namespace
  cluster_issuer_email                    = var.email
  cluster_issuer_name                     = "letsencrypt-${var.profile}"
  cluster_issuer_private_key_secret_name  = "letsencrypt-${var.profile}"
  cluster_issuer_server                   = "https://acme-staging-v02.api.letsencrypt.org/directory"
  #cluster_issuer_server                   = "https://acme-v02.api.letsencrypt.org/directory"
  
  solvers = [
    {
      http01 = {
        ingress = {
          class = "nginx"
        }
      }
    }
  ]
}