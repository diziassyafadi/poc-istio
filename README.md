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

Apply Istio policies and gateway resources:
```bash
kubectl apply -f infrastructure/istio-manifest
```
This includes a self-signed TLS certificate manifest for the gateway.

## Deploy applications
```bash
cd applications
./deploy-apps.sh
```

## Frontend via Istio gateway
The frontend is exposed through an Istio Gateway and VirtualService (no Kubernetes Ingress).

1. Add to `/etc/hosts` after the Istio ingress gateway has an external IP:
   ```text
   <INGRESS_LB_IP> poc-istio-fe.local
   ```
2. Access: https://poc-istio-fe.local/ (self-signed cert)

## mTLS verification
- Enforce mesh-wide mTLS: `infrastructure/istio-manifest/mtls.yaml`
- Verify with Istio CLI (if installed):
  ```bash
  istioctl authn tls-check -n frontend frontend-service
  ```
- Verify via sidecar metrics (after generating traffic to the frontend):
  ```bash
  kubectl -n frontend exec deploy/frontend -c istio-proxy -- \
    pilot-agent request GET stats/prometheus | \
    grep 'connection_security_policy="mutual_tls"'
  ```

## Notes
- Application values live under `applications/**/values.yaml`.
- Infra Helm releases are defined in `infrastructure/helm-release.tf`.
