# Infra

Multi-tenant SaaS app built on AWS

## Getting Started

### Requirements

- aws account
- install [terraform](https://www.terraform.io/)
- route53 hosted zone (not required for `local`)
- existing domain in hosted zone (not required for `local`)

### Setup
1. Navigate to desired SaaS environment `local/saas`, `dev/saas` etc.
2. Create you own `terraform.tfvars` file from the sample.

```
profile  = ""
region  = "eu-central-1"
stage   = "local"
hostname = "devpie.local"
email   = ""
```

3. Provision infrastructure for your environment.

```bash
terraform init
terraform apply
```

4. For `dev/saas`, register the app of apps with `argocd`.

```
argocd app create dev-apps \
    --dest-namespace argocd  \
    --dest-server https://kubernetes.default.svc  \
    --repo https://github.com/devpies/saas-infra.git \
    --path "manifests"
```
5. Then sync (deploy) the apps.
```
argocd app sync dev-apps 
```

### References

- [blog post: bootstrapping clusters with eks blueprints](https://aws.amazon.com/blogs/containers/bootstrapping-clusters-with-eks-blueprints/)
- [blog post: aws load balancer controller, acm, external-dns, and traefik](https://revolgy.com/blog/advanced-api-routing-in-eks-with-traefik-aws-loadbalancer-controller-and-external-dns/) 
- [argo cd](https://argoproj.github.io/argo-cd/getting_started/)
