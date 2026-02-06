# mTLS Verification Report

## Scope
1. Service-to-service communication uses Istio mTLS.
2. Mesh inbound (client → gateway) and outbound (gateway → services) use HTTPS/mTLS as applicable.
3. mTLS enforcement is enabled mesh-wide.

## Environment
- Cluster: k3d
- Istio ingress gateway with HTTPS (self-signed cert)
- Host: `poc-istio-fe.local`

## Test Cases and Results

| # | Test case | Command | Expected result | Actual result | Status |
|---|-----------|---------|-----------------|---------------|--------|
| 1 | Service-to-service communication uses mTLS | `istioctl proxy-config clusters -n frontend deploy/frontend --fqdn ads-service.ads.svc.cluster.local -o yaml \| sed -n '1,160p'` | Cluster shows `transportSocket` with TLS and SDS certs (Istio mTLS). | Observed `transportSocket: envoy.transport_sockets.tls` and SDS certs (`ROOTCA`). | PASS |
| 2 | Inbound/outbound uses HTTPS/mTLS | `curl -k --resolve poc-istio-fe.local:9443:127.0.0.1 https://poc-istio-fe.local:9443/`<br>`istioctl proxy-config clusters -n frontend deploy/frontend --fqdn ads-service.ads.svc.cluster.local -o yaml \| sed -n '1,160p'` | HTTPS handshake succeeds at gateway; downstream cluster uses Istio mTLS. | HTTPS access to gateway works (self-signed); downstream cluster uses Istio mTLS. | PASS |
| 3 | mTLS enforcement is enabled | `kubectl -n istio-system get peerauthentication default -o yaml`<br>`kubectl -n istio-system get destinationrule default -o yaml` | `PeerAuthentication` is `STRICT`; `DestinationRule` uses `ISTIO_MUTUAL`. | `STRICT` enabled; `ISTIO_MUTUAL` enabled. | PASS |

## Notes
- App-level HTTPS is not enabled; encryption is provided by Istio mTLS between sidecars.
- gRPC services run in plaintext at the app layer but are encrypted by the mesh.
