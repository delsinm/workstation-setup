#!/bin/bash

# --- Git Configuration Script ---

# --- Dependency Check ---
# Check for Git
if ! command -v git &> /dev/null; then
    echo "Error: 'git' is not installed."
    echo "Please install Git (https://git-scm.com/downloads) and try again."
    exit 1
fi

# Check for GitHub CLI (Optional but recommended for GitHub-specific tasks)
if ! command -v gh &> /dev/null; then
    echo "Warning: GitHub CLI ('gh') was not found."
    echo "You can still configure local Git settings, but remote GitHub features may be limited."
    read -p "Continue with basic Git configuration? (y/n): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "-----------------------------------------------"
echo " Initializing Git Global Configuration"
echo "-----------------------------------------------"

# Prompt for User Identity
read -p "Enter your full name: " git_name
read -p "Enter your GitHub email address: " git_email
read -p "Enter your GitHub username: " git_user

# Prompt for Preferences
read -p "Default branch name (default: main): " branch_name
branch_name=${branch_name:-main}

read -p "Preferred text editor (default: nano): " git_editor
git_editor=${git_editor:-nano}

echo -e "\nApplying configurations..."

# Executing Git Commands
git config --global user.name "$git_name"
git config --global user.email "$git_email"
git config --global github.user "$git_user"
git config --global init.defaultBranch "$branch_name"
git config --global core.editor "$git_editor"
git config --global color.ui auto

echo "-----------------------------------------------"
echo "Success! Your global settings are updated."
echo "-----------------------------------------------"
git config --list --global
