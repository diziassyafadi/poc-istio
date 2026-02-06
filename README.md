# Istio POC

Local POC for running the Online Boutique microservices demo with Istio on k3d.

## Prerequisites
- k3d cluster with context `k3d-k3s-default`
- kubectl
- helm
- terraform

## Infra (Istio)
```bash
cd infrastructure
terraform init
terraform apply
```

## Deploy applications
```bash
cd applications
./deploy-apps.sh
```

## Frontend ingress (Traefik)
The frontend creates a Kubernetes Ingress using the `traefik` class (k3d default).

1. Add a local host entry after the ingress is available:
   ```text
   <INGRESS_LB_IP> poc-istio-fe.local
   ```
2. Access: http://poc-istio-fe.local/

## Notes
- Application values live under `applications/**/values.yaml`.
- Infra Helm releases are defined in `infrastructure/helm-release.tf`.
