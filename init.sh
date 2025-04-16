#!/bin/bash
sudo apt update
sudo apt install git gcc make zsh curl ripgrep fd find bat fzf  python tldr locate -y

echo "[[ -s /usr/share/autojump/autojump.zsh ]] && source /usr/share/autojump/autojump.zsh" >> ~/.zshrc

curl https://raw.githubusercontent.com/ryanoasis/nerd-fonts/refs/heads/master/install.sh | bash


curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

# Add nvim to the PATH
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
echo "export PATH=\"\$PATH:/opt/nvim-linux-x86_64/bin\"" >> ~/.zshrc
# shellcheck source=/dev/null
source ~/.zshrc

# Linux uninstall script
rm -rf ~/.config/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.local/share/nvim

git clone https://github.com/NvChad/starter ~/.config/nvim && nvim
# git clone https://github.com/neovim/nvim-lspconfig ~/.config/nvim/pack/nvim/start/nvim-lspconfig