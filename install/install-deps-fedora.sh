#!/bin/bash
# Fedora Workstation Setup Script

set -eo pipefail

# --- Helpers ---
print_info() {
    echo -e "\n\033[1;34m[*] $1\033[0m"
}
print_success() {
    echo -e "\033[1;32m[+] $1\033[0m"  
}
print_warning() {
    echo -e "\033[1;33m[!] $1\033[0m"
}

# --- Main Functions ---
setup_repositories() {
    print_info "Updating system and setting up repositories..."
    dnf update -y
    
    dnf install -y \
      "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
      "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

    dnf copr enable -y scottames/ghostty
    print_success "Repositories configured."
}

install_dnf_packages() {
    print_info "Installing packages from DNF..."

    # Development Tools
    local DEV_TOOLS=( neovim rust cargo )

    # CLI Utilities
    local CLI_UTILS=(
        ghostty jq meld tmux tree fzf ripgrep shfmt
        the_silver_searcher yt-dlp zoxide git-delta
    )

    # Desktop Applications
    local DESKTOP_APPS=( ulauncher gnome-extensions-app gnome-browser-connector )

    dnf install -y "${DEV_TOOLS[@]}" "${CLI_UTILS[@]}" "${DESKTOP_APPS[@]}"
    print_success "DNF packages installed."
}

configure_autostart_apps() {
    print_info "Configuring autostart applications..."
    local ORIGINAL_USER="${SUDO_USER:-$(whoami)}"
    local AUTOSTART_DIR="/home/$ORIGINAL_USER/.config/autostart"

    # Configure Ulauncher to start on login
    sudo -u "$ORIGINAL_USER" mkdir -p "$AUTOSTART_DIR"
    sudo -u "$ORIGINAL_USER" bash -c "cat > '$AUTOSTART_DIR/ulauncher.desktop' << 'EOF'
[Desktop Entry]
Name=Ulauncher
Comment=Application launcher for Linux
Categories=GNOME;GTK;Utility;
Exec=ulauncher --hide-window
Terminal=false
Type=Application
StartupNotify=true
EOF"
    print_success "Autostart configured."
}

install_rust_tools() {
    print_info "Installing Rust-based tools with Cargo..."
    local CARGO_PACKAGES=( eza )

    for pkg in "${CARGO_PACKAGES[@]}"; do
        # Run installs as the original user
        if ! sudo -u "${SUDO_USER:-$(whoami)}" cargo install --list | grep -q "^$pkg "; then
            sudo -u "${SUDO_USER:-$(whoami)}" cargo install "$pkg"
        else
            print_warning "$pkg is already installed, skipping."
        fi
    done
    print_success "Rust tools installed."
}

install_node_tools() {
    print_info "Installing Node.js ecosystem tools (fnm, pnpm)..."
    local ORIGINAL_USER="${SUDO_USER:-$(whoami)}"
    local ORIGINAL_HOME; ORIGINAL_HOME=$(eval echo "~$ORIGINAL_USER")

    if ! command -v fnm &> /dev/null; then
        curl -fsSL https://fnm.vercel.app/install | sudo -u "$ORIGINAL_USER" bash -s -- --skip-shell
    else
        print_warning "fnm is already installed, skipping."
    fi

    if ! [ -f "$ORIGINAL_HOME/.local/share/pnpm/pnpm" ]; then
        curl -fsSL https://get.pnpm.io/install.sh | sudo -u "$ORIGINAL_USER" sh -
    else
        print_warning "pnpm seems to be installed, skipping."
    fi
    print_success "Node.js tools installed."
}

post_install_notes() {
    local ORIGINAL_HOME; ORIGINAL_HOME=$(eval echo "~${SUDO_USER:-$(whoami)}")
    
    print_info "--- IMPORTANT: Manual Steps Required ---"
    echo "
To complete the setup, you need to update your shell configuration file
(e.g., ~/.bashrc or ~/.zshrc) with the following lines:

# For Rust / Cargo
export PATH=\"$ORIGINAL_HOME/.cargo/bin:\$PATH\"

# For FNM (Node Version Manager)
eval \"\$(fnm env --use-on-cd)\"

# For PNPM
export PNPM_HOME=\"$ORIGINAL_HOME/.local/share/pnpm\"
case \":\$PATH:\" in
  *:\$PNPM_HOME:*) ;;
  *) export PATH=\"\$PNPM_HOME:\$PATH\" ;;
esac

After saving the file, restart your terminal or run: source ~/.bashrc
"
}

# --- Main Execution ---
main() {
    if [[ $EUID -ne 0 ]]; then
       echo "This script must be run with sudo: sudo ./setup.sh" 
       exit 1
    fi

    setup_repositories
    install_dnf_packages
    configure_autostart_apps
    install_rust_tools
    install_node_tools
    post_install_notes
    
    print_success "Fedora setup script finished!"
}

main
