# Local Ops Workspace 💻

A professional, version-pinned environment for Infrastructure Architecture and DevOps workflows. 

This repository manages my local **Management Plane**—the control station used to orchestrate decentralized infrastructure (**DeCloud**) across Hetzner, Cloudflare, and local Talos/Kubernetes clusters.

## 🎯 Workspace Philosophy
- **Declarative Infrastructure:** Zero manual binary downloads. Everything is managed via `mise`.
- **Portability:** Instant migration between machines (Fedora/macOS) with 100% tool parity.
- **Context Awareness:** Directory-specific tool versions via cascading `.mise.toml` configurations.

## 🛠️ Integrated Toolchain

| Category | Tools | Purpose |
| :--- | :--- | :--- |
| **Provisioning** | Terraform, Terragrunt | Multi-cloud orchestration (v1.0.0+) |
| **OS & K8s** | Talosctl, Kubectl, Helm 4 | Cluster lifecycle & package management |
| **GitOps** | Flux2 | Continuous Delivery and OCI reconciliation |
| **Observability**| K9s, jq, yq | Real-time monitoring & data parsing |
| **Productivity** | fzf, usage | Fuzzy search and CLI auto-completion |

---

## 🚀 New Machine Setup (Bootstrap)

You can hydrate your environment on a fresh OS using either the **Automated One-Step Script** or the **Manual Setup**.

## Option A: Automated One-Step Hydration
If you are on a fresh OS, you can bootstrap everything (install mise, clone the repo, link config, and install tools) with a single command:

```bash
curl -sSL https://raw.githubusercontent.com/init-cerebra/ops-workspace/main/init.sh | bash
```
>
**Note: After the script finishes, add eval "$(~/.local/bin/mise activate bash)" to your ~/.bashrc or ~/.zshrc.**

## Option B: Manual Setup
If you prefer to configure the workspace step-by-step:

### 1. Install mise (The Engine)
curl https://mise.jdx.dev/install.sh | sh

### 2. Clone & Sync Configuration
```bash
git clone https://github.com/init-cerebra/ops-workspace.git ~/work-env
mkdir -p ~/.config/mise
ln -sf ~/work-env/config.toml ~/.config/mise/config.toml
```

### 3. Initialize Environment
Add the following to your ~/.bashrc or ~/.zshrc:
eval "$(~/.local/bin/mise activate bash)"

Then, install all pinned binaries:
mise install
mise reshim

---

## 📂 Global Configuration (config.toml)
```toml
[tools]
# --- IaC Stack ---
terraform = "1.14.8"
terragrunt = "1.0.0"
talos = "1.12.6"

# --- K8s Control Plane ---
kubectl = "1.35.3"
k9s = "0.50.18"
helm = "4.1.3"
flux2 = "2.8.3"

# --- Local Development ---
kind = "0.31.0"
"aqua:kubernetes-sigs/cloud-provider-kind" = "0.10.0"

# --- CLI Utilities ---
fzf = "0.70.0"
usage = "3.2.0"
jq = "1.8.1"
yq = "4.52.5"

[settings]
autoinstall = true
yes = true
shims_dir = "~/.local/share/mise/shims"
all_backend_refresh = "24h"

---
## ⚡ Productivity Aliases (Recommended)

Add these to your shell profile to speed up daily operations:

# Kubernetes
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgn='kubectl get nodes'

# Tools
alias tf='terraform'
alias tg='terragrunt'
alias tctl='talosctl'

# mise
alias m='mise'
alias mls='mise ls --installed'

---
*Architected for high-performance DevOps and digital sovereignty.*
```
