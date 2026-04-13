#!/bin/bash

# --- Mac setup script ---

# --- Helper Functions ---
print_status() { echo -e "\n\033[1;34m[INFO]\033[0m $1"; }
print_success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }
print_error() { echo -e "\033[1;31m[ERROR]\033[0m $1"; }

printf "\nRunning Mac setup workflow...\n\n"

# --- 1. Homebrew Check/Install ---
if ! command -v brew &> /dev/null; then
    print_status "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    [[ $(uname -m) == "arm64" ]] && eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(/usr/local/bin/brew shellenv)"
else
    print_success "Homebrew ready."
fi

# --- 2. Install Packages (Filters for "true") ---
PACKAGE_FILE="packages.json"
if [[ -f "$PACKAGE_FILE" ]]; then
    print_status "Processing $PACKAGE_FILE..."
    
    # Filter JSON for keys where value is true
    packages=$(python3 -c "import json; data = json.load(open('$PACKAGE_FILE')); print(' '.join([k for k, v in data.items() if v is True]))" 2>/dev/null)
    
    for pkg in $packages; do
        if brew list --formula | grep -qx "$pkg"; then
            print_success "$pkg already installed, skipping."
        else
            print_status "Installing $pkg..."
            brew install "$pkg" --quiet && print_success "$pkg installed" || print_error "Failed: $pkg"
        fi
    done
else
    print_error "$PACKAGE_FILE missing."
fi

# --- 3. Create .vimrc ---
print_status "Creating ~/.vimrc..."
cat > "$HOME/.vimrc" << 'EOF'
" Enable syntax highlighting
syntax on

" Use the mouse (useful for scrolling and resizing splits)
set mouse=a

" Show line numbers (relative numbers are great for jumping lines)
set number
set relativenumber
EOF
print_success "~/.vimrc created."

# --- 4. VS Code Extensions (Filters for "true") ---
EXTENSION_FILE="extensions.json"
if command -v code &> /dev/null && [[ -f "$EXTENSION_FILE" ]]; then
    print_status "Installing VS Code extensions..."
    
    extensions=$(python3 -c "import json; data = json.load(open('$EXTENSION_FILE')); print(' '.join([k for k, v in data.items() if v is True]))" 2>/dev/null)
    
    for ext in $extensions; do
        print_status "Adding $ext..."
        code --install-extension "$ext" --force &>/dev/null && print_success "$ext added" || print_error "Failed: $ext"
    done
elif [[ ! -f "$EXTENSION_FILE" ]]; then
    print_error "$EXTENSION_FILE missing."
fi

echo ""
print_success "Workflow complete."
