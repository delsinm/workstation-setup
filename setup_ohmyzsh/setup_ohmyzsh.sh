#!/bin/bash

# --- OhMyZsh! Configuration Script ---

# --- 1. Install Oh My Zsh ---
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is already installed. Skipping download..."
else
    echo "Downloading and installing Oh My Zsh..."
    # RUNZSH=no prevents the installer from opening a new zsh session immediately
    # KEEP_ZSHRC=yes prevents it from overwriting your existing .zshrc
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSHRC="$HOME/.zshrc"

# --- 2. Enable robbyrussell Theme ---
echo "Setting theme to robbyrussell..."
# Using a slightly different sed syntax to handle different OS environments
sed -i -e 's/^ZSH_THEME=".*"/ZSH_THEME="robbyrussell"/' "$ZSHRC"

# --- 3. Enable Plugins ---
echo "Configuring plugins..."
# This targets the line starting with plugins=(...) and replaces the contents
TARGET_PLUGINS="docker gh helm pip 1password ssh kubectl kubectx aws terraform minikube sudo history git"
sed -i -e "s/^plugins=(.*)/plugins=($TARGET_PLUGINS)/" "$ZSHRC"

# --- 4. Configure Prompt ---
echo "Configuring prompt to display full path..."

# Override robbyrussell theme to show full path
# grep guard ensures this is only appended once, keeping the script idempotent
if grep -qF 'PROMPT=' "$ZSHRC"; then
    echo "Prompt already configured, skipping."
else
    cat >> "$ZSHRC" << 'EOF'

# Override robbyrussell theme to show full path
PROMPT='${ret_status} %{$fg_bold[white]%}%~%{$reset_color%} $(git_prompt_info)'
EOF
fi

echo "-----------------------------------------------"
echo " Configuration Complete!"
echo " Please run: source ~/.zshrc"
echo "-----------------------------------------------"
