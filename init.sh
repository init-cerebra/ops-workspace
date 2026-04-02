#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Starting Local Ops hydration...${NC}"

# 1. Install mise if not present
if ! command -v mise &> /dev/null && [ ! -f "$HOME/.local/bin/mise" ]; then
    echo -e "${BLUE}📦 Installing mise...${NC}"
    curl https://mise.jdx.dev/install.sh | sh
fi
export PATH="$HOME/.local/bin:$PATH"

# 2. Clone/Update the Workspace Repo
TARGET_DIR="$HOME/work-env"
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${BLUE}📂 Cloning repository...${NC}"
    git clone https://github.com/init-cerebra/ops-workspace.git "$TARGET_DIR"
else
    echo -e "${GREEN}✅ Workspace directory exists. Updating...${NC}"
    cd "$TARGET_DIR" && git pull && cd - > /dev/null
fi

# 3. Symlink the config file
echo -e "${BLUE}🔗 Linking config.toml...${NC}"
mkdir -p "$HOME/.config/mise"
ln -sf "$TARGET_DIR/config.toml" "$HOME/.config/mise/config.toml"

# 4. Install all tools defined in that config
echo -e "${BLUE}🛠  mise: Installing packages...${NC}"
"$HOME/.local/bin/mise" install --yes
"$HOME/.local/bin/mise" reshim

# 5. Inject Aliases and Zoxide initialization
CONF_FILE=""
[ -f "$HOME/.zshrc" ] && CONF_FILE="$HOME/.zshrc"
[ -f "$HOME/.bashrc" ] && CONF_FILE="$HOME/.bashrc"

if [ -n "$CONF_FILE" ] && ! grep -q "OPS-WORKSPACE ALIASES" "$CONF_FILE"; then
    echo -e "${BLUE}📝 Adding aliases to $CONF_FILE...${NC}"
    cat <<EOT >> "$CONF_FILE"

# --- OPS-WORKSPACE ALIASES ---
eval "\$($HOME/.local/bin/mise activate $(basename $SHELL))"
# Initialize zoxide with command 'j' (jump)
eval "\$($HOME/.local/bin/zoxide init $(basename $SHELL) --cmd j)"
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
fi

echo -e "\n${GREEN}✅ Success! All tools ready. Use 'j <folder_name>' to jump around.${NC}"
echo -e "${BLUE}👉 Run: source $CONF_FILE${NC}"