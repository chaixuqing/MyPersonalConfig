#!/bin/bash

# WSL2 Modern Development Environment Setup Script
# Enhanced with modern tools and better error handling

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Progress tracking
TOTAL_STEPS=12
CURRENT_STEP=0

show_progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo -e "${BLUE}[${CURRENT_STEP}/${TOTAL_STEPS}]${NC} $1"
}

# Error handling
handle_error() {
    log_error "Script failed at line $1"
    exit 1
}

trap 'handle_error $LINENO' ERR

# Check if running on WSL2
check_wsl2() {
    if ! grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null; then
        log_warning "This script is optimized for WSL2 but will continue anyway"
    fi
}

# System update and basic packages
install_system_packages() {
    show_progress "Updating system and installing basic packages..."
    
    sudo apt update && sudo apt upgrade -y
    
    # Essential packages (excluding nodejs/npm to avoid conflicts)
    sudo apt install -y \
        curl wget git build-essential \
        zsh fzf tldr tree nnn shellcheck \
        fontconfig tmux ranger neofetch \
        gcc make ninja-build g++ \
        python3 python3-pip \
        unzip software-properties-common \
        apt-transport-https ca-certificates \
        gnupg lsb-release \
        pkg-config libssl-dev libffi-dev \
        libsqlite3-dev libreadline-dev \
        libbz2-dev libncurses5-dev libgdbm-dev \
        liblzma-dev tk-dev uuid-dev
    
    log_success "System packages installed successfully"
}

# Install modern package managers
install_package_managers() {
    show_progress "Installing modern package managers..."
    
    # Install Node.js via NodeSource repository (avoids Ubuntu package conflicts)
    if ! command -v node &> /dev/null; then
        log_info "Installing Node.js via NodeSource..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
    
    # Install uv (ultra-fast Python package manager)
    if ! command -v uv &> /dev/null; then
        log_info "Installing uv (Python package manager)..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        # shellcheck disable=SC1090
        source ~/.local/bin/env 2>/dev/null || true
    fi
    
    # Install pnpm (fast Node.js package manager)
    if ! command -v pnpm &> /dev/null; then
        log_info "Installing pnpm..."
        npm install -g pnpm
    fi
    
    # Install bun (ultra-fast JavaScript runtime)
    if ! command -v bun &> /dev/null; then
        log_info "Installing bun..."
        curl -fsSL https://bun.sh/install | bash
        # shellcheck disable=SC1090
        source ~/.bashrc 2>/dev/null || true
    fi
    
    log_success "Package managers installed successfully"
}

# Install Rust and minimal Cargo tools
install_rust_ecosystem() {
    show_progress "Installing Rust and essential tools..."
    
    # Install Rust if not present (some tools still need it)
    if ! command -v cargo &> /dev/null; then
        log_info "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source $HOME/.cargo/env
    fi
    
    # Only install essential tools that compile quickly via cargo
    ESSENTIAL_CARGO_TOOLS=(
        "tokei"                 # Code statistics (compiles fast)
        "hyperfine"             # Benchmarking tool (compiles fast)
    )
    
    for tool in "${ESSENTIAL_CARGO_TOOLS[@]}"; do
        if ! cargo install --list | grep -q "$tool"; then
            log_info "Installing $tool via cargo..."
            if timeout 120 cargo install $tool; then
                log_success "$tool installed successfully"
            else
                log_warning "Failed to install $tool, skipping..."
            fi
        fi
    done
    
    log_success "Essential Rust tools installed"
}

# Install modern tools via pre-compiled binaries
install_precompiled_tools() {
    show_progress "Installing modern tools via pre-compiled binaries..."
    
    # Create local bin directory
    mkdir -p ~/.local/bin
    
    # Install eza (modern ls replacement)
    if ! command -v eza &> /dev/null; then
        log_info "Installing eza..."
        EZA_VERSION=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep tag_name | cut -d '"' -f 4)
        wget -q "https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz" -O /tmp/eza.tar.gz
        tar -xzf /tmp/eza.tar.gz -C /tmp/
        sudo mv /tmp/eza /usr/local/bin/
        rm -f /tmp/eza.tar.gz
    fi
    
    # Install fd (modern find replacement)
    if ! command -v fd &> /dev/null; then
        log_info "Installing fd..."
        FD_VERSION=$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | grep tag_name | cut -d '"' -f 4)
        wget -q "https://github.com/sharkdp/fd/releases/download/${FD_VERSION}/fd-${FD_VERSION}-x86_64-unknown-linux-gnu.tar.gz" -O /tmp/fd.tar.gz
        tar -xzf /tmp/fd.tar.gz -C /tmp/
        sudo mv /tmp/fd-*/fd /usr/local/bin/
        rm -rf /tmp/fd* /tmp/fd.tar.gz
    fi
    
    # Install bat (enhanced cat)
    if ! command -v bat &> /dev/null; then
        log_info "Installing bat..."
        BAT_VERSION=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | grep tag_name | cut -d '"' -f 4)
        wget -q "https://github.com/sharkdp/bat/releases/download/${BAT_VERSION}/bat-${BAT_VERSION}-x86_64-unknown-linux-gnu.tar.gz" -O /tmp/bat.tar.gz
        tar -xzf /tmp/bat.tar.gz -C /tmp/
        sudo mv /tmp/bat-*/bat /usr/local/bin/
        rm -rf /tmp/bat* /tmp/bat.tar.gz
    fi
    
    # Install ripgrep (ultra-fast grep)
    if ! command -v rg &> /dev/null; then
        log_info "Installing ripgrep..."
        RG_VERSION=$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep tag_name | cut -d '"' -f 4)
        wget -q "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz" -O /tmp/rg.tar.gz
        tar -xzf /tmp/rg.tar.gz -C /tmp/
        sudo mv /tmp/ripgrep-*/rg /usr/local/bin/
        rm -rf /tmp/ripgrep* /tmp/rg.tar.gz
    fi
    
    # Install zoxide (smart cd replacement)
    if ! command -v zoxide &> /dev/null; then
        log_info "Installing zoxide..."
        ZOXIDE_VERSION=$(curl -s https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest | grep tag_name | cut -d '"' -f 4)
        wget -q "https://github.com/ajeetdsouza/zoxide/releases/download/${ZOXIDE_VERSION}/zoxide-${ZOXIDE_VERSION}-x86_64-unknown-linux-musl.tar.gz" -O /tmp/zoxide.tar.gz
        tar -xzf /tmp/zoxide.tar.gz -C /tmp/
        sudo mv /tmp/zoxide /usr/local/bin/
        rm -f /tmp/zoxide.tar.gz
    fi
    
    # Install starship (cross-shell prompt)
    if ! command -v starship &> /dev/null; then
        log_info "Installing starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
    
    # Install dust (intuitive du replacement)
    if ! command -v dust &> /dev/null; then
        log_info "Installing dust..."
        DUST_VERSION=$(curl -s https://api.github.com/repos/bootandy/dust/releases/latest | grep tag_name | cut -d '"' -f 4)
        wget -q "https://github.com/bootandy/dust/releases/download/${DUST_VERSION}/dust-${DUST_VERSION}-x86_64-unknown-linux-gnu.tar.gz" -O /tmp/dust.tar.gz
        tar -xzf /tmp/dust.tar.gz -C /tmp/
        sudo mv /tmp/dust-*/dust /usr/local/bin/
        rm -rf /tmp/dust* /tmp/dust.tar.gz
    fi
    
    # Install procs (modern ps replacement)
    if ! command -v procs &> /dev/null; then
        log_info "Installing procs..."
        PROCS_VERSION=$(curl -s https://api.github.com/repos/dalance/procs/releases/latest | grep tag_name | cut -d '"' -f 4)
        wget -q "https://github.com/dalance/procs/releases/download/${PROCS_VERSION}/procs-${PROCS_VERSION}-x86_64-linux.zip" -O /tmp/procs.zip
        unzip -q /tmp/procs.zip -d /tmp/
        sudo mv /tmp/procs /usr/local/bin/
        rm -f /tmp/procs.zip
    fi
    
    # Install mise (runtime manager) via direct binary
    if ! command -v mise &> /dev/null; then
        log_info "Installing mise..."
        # Try the official installer first
        if curl -fsSL https://mise.run | sh; then
            log_success "mise installed successfully"
        else
            log_warning "Official installer failed, trying alternative method..."
            # Alternative: Direct binary download
            MISE_VERSION=$(curl -s https://api.github.com/repos/jdx/mise/releases/latest | grep tag_name | cut -d '"' -f 4)
            if [ -n "$MISE_VERSION" ]; then
                wget -q "https://github.com/jdx/mise/releases/download/${MISE_VERSION}/mise-${MISE_VERSION}-linux-x64.tar.gz" -O /tmp/mise.tar.gz
                if [ -f /tmp/mise.tar.gz ]; then
                    tar -xzf /tmp/mise.tar.gz -C /tmp/
                    sudo mv /tmp/mise/bin/mise /usr/local/bin/
                    rm -rf /tmp/mise /tmp/mise.tar.gz
                    log_success "mise installed via direct binary"
                else
                    log_warning "Could not install mise, you can install it manually later with: curl https://mise.run | sh"
                fi
            else
                log_warning "Could not determine mise version, skipping installation"
            fi
        fi
        
        # Add to PATH if installed
        if command -v mise &> /dev/null; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        fi
    fi
    
    log_success "Pre-compiled tools installed successfully"
}

# Install additional modern tools
install_additional_tools() {
    show_progress "Installing additional modern tools..."
    
    # Install btop++ (modern htop replacement)
    if ! command -v btop &> /dev/null; then
        log_info "Installing btop++..."
        wget -qO btop.tbz https://github.com/aristocratos/btop/releases/latest/download/btop-x86_64-linux-musl.tbz
        tar xf btop.tbz && sudo mv btop/bin/btop /usr/local/bin/
        rm -rf btop btop.tbz
    fi
    
    # Install duf (modern df replacement)
    if ! command -v duf &> /dev/null; then
        log_info "Installing duf..."
        DUF_VERSION=$(curl -s https://api.github.com/repos/muesli/duf/releases/latest | grep tag_name | cut -d '"' -f 4)
        wget -q "https://github.com/muesli/duf/releases/download/${DUF_VERSION}/duf_${DUF_VERSION#v}_linux_x86_64.deb"
        sudo dpkg -i "duf_${DUF_VERSION#v}_linux_x86_64.deb" 2>/dev/null || true
        rm -f "duf_${DUF_VERSION#v}_linux_x86_64.deb"
    fi
    
    # Install lazydocker (Docker management TUI)
    if ! command -v lazydocker &> /dev/null; then
        log_info "Installing lazydocker..."
        LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazydocker.tar.gz lazydocker
        sudo install lazydocker /usr/local/bin
        rm -f lazydocker.tar.gz lazydocker
    fi
    
    log_success "Additional tools installed successfully"
}

# Setup Zsh and Oh My Zsh
setup_zsh() {
    show_progress "Setting up Zsh and Oh My Zsh..."
    
    # Install Oh My Zsh if not present
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    # Install Zsh plugins
    PLUGINS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    
    if [ ! -d "$PLUGINS_DIR/zsh-autosuggestions" ]; then
        log_info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGINS_DIR/zsh-autosuggestions"
    fi
    
    if [ ! -d "$PLUGINS_DIR/zsh-syntax-highlighting" ]; then
        log_info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGINS_DIR/zsh-syntax-highlighting"
    fi
    
    log_success "Zsh setup completed"
}

# Configure shell integrations
configure_shell() {
    show_progress "Configuring shell integrations and aliases..."
    
    # Backup existing .zshrc
    [ -f ~/.zshrc ] && cp ~/.zshrc ~/.zshrc.backup."$(date +%Y%m%d_%H%M%S)"
    
    # Configure Oh My Zsh settings and plugins
    cat >> ~/.zshrc << 'EOL'

# Oh My Zsh configuration
zstyle ':omz:update' mode auto
zstyle ':omz:alpha:lib:git' async-prompt force
zstyle ':omz:update' frequency 7

# Plugin configuration
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    fzf
)

# Modern CLI tool integrations
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

if command -v mcfly &> /dev/null; then
    eval "$(mcfly init zsh)"
fi

if command -v mise &> /dev/null; then
    eval "$(mise activate zsh)"
fi

# Modern aliases
if command -v eza &> /dev/null; then
    alias ls="eza --icons"
    alias ll="eza -l --icons"
    alias la="eza -la --icons"
    alias tree="eza --tree"
fi

if command -v bat &> /dev/null; then
    alias cat="bat"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

if command -v fd &> /dev/null; then
    alias find="fd"
fi

if command -v bottom &> /dev/null; then
    alias htop="btm"
fi

if command -v dust &> /dev/null; then
    alias du="dust"
fi

if command -v duf &> /dev/null; then
    alias df="duf"
fi

if command -v procs &> /dev/null; then
    alias ps="procs"
fi

# Useful aliases
alias grep="rg"
alias top="btop"
alias vim="micro"
alias ..="cd .."
alias ...="cd ../.."
alias l="ls -la"
alias h="history"
alias c="clear"

# Git aliases
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gb="git branch"
alias gco="git checkout"

# Python with uv
if command -v uv &> /dev/null; then
    alias pip="uv pip"
    alias python="uv run python"
fi

# Add local bin to PATH
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# FZF configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

EOL
    
    log_success "Shell configuration completed"
}

# Configure Git
configure_git() {
    show_progress "Configuring Git with modern settings..."
    
    # Copy the enhanced .gitconfig if it exists
    if [ -f "$(dirname "$0")/.gitconfig" ]; then
        cp "$(dirname "$0")/.gitconfig" ~/.gitconfig
        log_info "Enhanced .gitconfig copied"
    fi
    
    log_success "Git configuration completed"
}

# Setup development environments
setup_development() {
    show_progress "Setting up development environments..."
    
    # Setup Python with uv
    if command -v uv &> /dev/null; then
        log_info "Setting up Python environment..."
        uv python install 3.12
        uv tool install ipython black isort flake8 mypy pytest
    fi
    
    # Setup Node.js with latest LTS
    if command -v mise &> /dev/null; then
        log_info "Setting up Node.js environment..."
        mise install node@lts
        mise global node@lts
    fi
    
    log_success "Development environments setup completed"
}

# WSL2 optimizations
optimize_wsl2() {
    show_progress "Applying WSL2 optimizations..."
    
    # Enable systemd if not already enabled
    if ! grep -q "systemd=true" /etc/wsl.conf 2>/dev/null; then
        log_info "Enabling systemd support..."
        echo -e "[boot]\nsystemd=true" | sudo tee -a /etc/wsl.conf
    fi
    
    # Configure Git to use Windows credential manager if available
    if [ -f "/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe" ]; then
        git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"
        log_info "Git credential manager configured"
    fi
    
    log_success "WSL2 optimizations applied"
}

# Final setup and cleanup
finalize_setup() {
    show_progress "Finalizing setup..."
    
    # Update shell completions
    if command -v zsh &> /dev/null; then
        zsh -c "autoload -U compinit && compinit" 2>/dev/null || true
    fi
    
    # Clean up package cache
    sudo apt autoremove -y
    sudo apt autoclean
    
    log_success "Setup finalized and cleaned up"
}

# Display completion message
show_completion() {
    show_progress "Setup completed successfully!"
    
    echo -e "\n${GREEN}🎉 WSL2 Modern Development Environment Setup Complete!${NC}\n"
    echo -e "${BLUE}Next steps:${NC}"
    echo -e "1. Restart your terminal or run: ${YELLOW}exec zsh${NC}"
    echo -e "2. (Optional) Restart WSL2 for systemd: ${YELLOW}wsl --shutdown${NC} then reopen"
    echo -e "3. Configure starship prompt: ${YELLOW}starship config${NC}"
    echo -e "4. Test new tools: ${YELLOW}eza, fd, zoxide, bat, btop${NC}"
    
    echo -e "\n${BLUE}Installed modern tools:${NC}"
    echo -e "• File operations: eza, fd, zoxide, bat, ripgrep"
    echo -e "• System monitoring: btop, bottom, dust, duf, procs"
    echo -e "• Development: uv, mise, pnpm, bun, starship"
    echo -e "• Utilities: hyperfine, tokei, mcfly, lazydocker"
    
    echo -e "\n${GREEN}Happy coding! 🚀${NC}\n"
}

# Main execution
main() {
    log_info "Starting WSL2 Modern Development Environment Setup..."
    
    check_wsl2
    install_system_packages
    install_package_managers
    install_rust_ecosystem
    install_precompiled_tools
    install_additional_tools
    setup_zsh
    configure_shell
    configure_git
    setup_development
    optimize_wsl2
    finalize_setup
    show_completion
}

# Run main function
main "$@"