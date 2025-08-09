sudo dnf update -y
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf install -y kitty
curl -fsSL https://fnm.vercel.app/install | bash
curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
curl -fsSL https://get.pnpm.io/install.sh | sh -
sudo dnf install -y neovim
sudo dnf install -y rust cargo

cargo install eza
sudo dnf install -y jq
sudo dnf install -y meld
sudo dnf install -y tmux
sudo dnf install -y tree
sudo dnf install -y fzf
sudo dnf install -y ripgrep
sudo dnf install -y shfmt
sudo dnf install -y the_silver_searcher
sudo dnf install -y yt-dlp
sudo dnf install -y zoxide
sudo dnf install git-delta
