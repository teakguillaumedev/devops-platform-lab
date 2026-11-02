#!/usr/bin/env bash
# Creates the local Kubernetes cluster used by the K scenarios: kind, 1 control plane + 2 workers.
# Requires Docker running in WSL2. Usage: ./setup-kind.sh [create|delete]
set -euo pipefail

KIND_VERSION=v0.27.0     # kind >= 0.24: its default CNI (kindnet) enforces NetworkPolicies (needed by K09)
CLUSTER=tshoot

install_tools() {
  if ! command -v kind >/dev/null; then
    echo ">> installing kind $KIND_VERSION"
    curl -fsSLo /tmp/kind "https://kind.sigs.k8s.io/dl/$KIND_VERSION/kind-linux-amd64"
    sudo install -m 0755 /tmp/kind /usr/local/bin/kind
  fi
  if ! command -v kubectl >/dev/null; then
    echo ">> installing kubectl (latest stable)"
    curl -fsSLo /tmp/kubectl "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -m 0755 /tmp/kubectl /usr/local/bin/kubectl
  fi
}

create() {
  install_tools
  if kind get clusters 2>/dev/null | grep -qx "$CLUSTER"; then
    echo ">> cluster $CLUSTER already exists"
  else
    kind create cluster --name "$CLUSTER" --config - <<'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
EOF
  fi
  kubectl config use-context "kind-$CLUSTER" >/dev/null
  kubectl get nodes
  echo ">> pre-pulling the scenario images into the nodes (faster scenarios)"
  for img in nginx:1.27-alpine busybox:1.36 python:3.12-alpine; do
    docker pull -q "$img" >/dev/null && kind load docker-image "$img" --name "$CLUSTER" >/dev/null && echo "   $img"
  done
}

delete() { kind delete cluster --name "$CLUSTER"; }

"${1:-create}"
