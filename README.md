# Sreehari S — Accuknox DevOps Trainee Practical Assessment

This repository contains my submission for the Accuknox DevOps Trainee practical assessment, covering PS1 (Wisecow containerization & Kubernetes deployment) and PS2 (system/application health scripts).

## Repository structure

```
.
├── .github/workflows/
│   └── docker-build-push.yml   # CI/CD: build, push to GHCR, deploy to cluster
├── ps1-wisecow/
│   ├── Dockerfile
│   ├── wisecow.sh
│   ├── wisecow-deployment.yaml
│   ├── wisecow-service.yaml
│   ├── wisecow-ingress.yaml
│   ├── tls.crt / tls.key       # self-signed cert for local TLS demo
├── ps2-scripts/
│   ├── health_monitor.sh       # system health monitoring (Bash)
│   └── app_health_checker.py   # application health checker (Python)
└── README.md
```

## PS1 — Wisecow on Kubernetes

**What it does:** Containerizes the [Wisecow](https://github.com/nyrahul/wisecow) app and deploys it to a local Kind Kubernetes cluster with a full CI/CD pipeline and TLS termination.

- **Dockerfile** — builds an Ubuntu-based image with `fortune-mod`, `cowsay`, and `netcat`, running `wisecow.sh` on port 4499.
- **Kubernetes manifests** — a `Deployment` (2 replicas) and a `NodePort` `Service` exposing the app.
- **CI/CD (GitHub Actions)** —
  - `build-and-push`: builds the Docker image and pushes it to `ghcr.io/zree77/wisecow:latest` on every push to `main`.
  - `deploy`: runs on a self-hosted runner (my machine, since the cluster is local) and applies the manifests + restarts the deployment so it picks up the freshly pushed image.
- **TLS** — an NGINX Ingress controller terminates HTTPS using a self-signed certificate (`tls.crt`/`tls.key`, stored as a Kubernetes Secret), fronting the Service.

**To reproduce locally:**
```bash
cd ps1-wisecow
docker build -t wisecow:v1 .
kind create cluster --name wisecow-cluster
kind load docker-image wisecow:v1 --name wisecow-cluster
kubectl apply -f wisecow-deployment.yaml
kubectl apply -f wisecow-service.yaml
kubectl apply -f wisecow-ingress.yaml
```

## PS2 — Scripts

Two of the four listed objectives were implemented:

1. **System Health Monitoring** (`ps2-scripts/health_monitor.sh`, Bash) — checks CPU, memory, disk usage, and running process count against thresholds, logging alerts to `health_monitor.log`.
   ```bash
   ./ps2-scripts/health_monitor.sh
   ```

2. **Application Health Checker** (`ps2-scripts/app_health_checker.py`, Python) — checks whether a target app is up or down based on its HTTP status code. Defaults to checking the local Wisecow service, but accepts any URL as an argument.
   ```bash
   python3 ps2-scripts/app_health_checker.py [optional_url]
   ```

## Notes

- `imagePullPolicy` in the Deployment is set to `Always`, pulling from GHCR so the CD pipeline's freshly built image is always picked up.
- The self-signed TLS cert is included for demo/reproducibility purposes only — not intended for production trust.
-
