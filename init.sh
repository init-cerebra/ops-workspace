#!/bin/bash
set -e

# Кольори для виводу
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Starting Clean Ops hydration...${NC}"

# 1. Встановлення mise (якщо немає)
if ! command -v mise &> /dev/null && [ ! -f "$HOME/.local/bin/mise" ]; then
    echo -e "${BLUE}📦 Installing mise...${NC}"
    curl https://mise.jdx.dev/install.sh | sh
fi

# Тимчасово додаємо шлях для поточної сесії скрипта
export PATH="$HOME/.local/bin:$PATH"

# 2. Клонування/Оновлення репозиторію
TARGET_DIR="$HOME/work-env"
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${BLUE}📂 Cloning workspace repo...${NC}"
    git clone https://github.com/init-cerebra/ops-workspace.git "$TARGET_DIR"
else
    echo -e "${GREEN}✅ Workspace directory exists. Updating...${NC}"
    cd "$TARGET_DIR" && git pull && cd - > /dev/null
fi

# 3. Створення лінку на config.toml
echo -e "${BLUE}🔗 Linking config.toml...${NC}"
mkdir -p "$HOME/.config/mise"
ln -sf "$TARGET_DIR/config.toml" "$HOME/.config/mise/config.toml"

# 4. Інсталяція інструментів (Terraform, K8s stack, etc.)
echo -e "${BLUE}🛠  mise: Installing tools...${NC}"
mise install --yes
mise reshim

# 5. Ін'єкція твого блоку аліасів та PATH у профіль
CONF_FILE=""
if [ -f "$HOME/.zshrc" ]; then CONF_FILE="$HOME/.zshrc"; 
else CONF_FILE="$HOME/.bashrc"; fi

# Видаляємо старий блок, якщо він був (для чистоти при перевстановленні)
sed -i '/# --- OPS-WORKSPACE CONFIG ---/,/# -----------------------------/d' "$CONF_FILE" 2>/dev/null || true

echo -e "${BLUE}📝 Injecting clean config into $CONF_FILE...${NC}"
cat <<EOT >> "$CONF_FILE"

# --- OPS-WORKSPACE CONFIG ---
# Додаємо локальні бінарники в PATH
export PATH="\$HOME/.local/bin:\$PATH"

# Активуємо mise
eval "\$($HOME/.local/bin/mise activate \$(basename \$SHELL))"

# Аліаси
alias cat='bat'
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgn='kubectl get nodes'
alias tf='terraform'
alias tg='terragrunt'
alias tctl='talosctl'
alias m='mise'
alias mls='mise ls --installed'
# -----------------------------
EOT

echo -e "\n${GREEN}✨ SUCCESS! Environment is clean and automated.${NC}"
echo -e "${BLUE}👉 Run: ${YELLOW}source $CONF_FILE${NC}"