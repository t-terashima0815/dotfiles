#!/usr/bin/env bash

DOTFILES="$(pwd)"
GRAPHICAL_TARGET=[[ "$(sudo systemctl get-default)" == 'graphical.target' ]]
COLOR_GRAY="\033[1;38;5;243m"
COLOR_BLUE="\033[1;34m"
COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"
COLOR_PURPLE="\033[1;35m"
COLOR_YELLOW="\033[1;33m"
COLOR_NONE="\033[0m"

title() {
  echo -e "\n${COLOR_PURPLE}$1${COLOR_PURPLE}"
  echo -e "${COLOR_GRAY}=================================${COLOR_NONE}\n"
}

error() {
  echo -e "${COLOR_RED}Error: ${COLOR_NONE}$1"
  exit 1
}

warning() {
  echo -e "${COLOR_YELLOW}Warning: ${COLOR_NONE}$1"
}

info() {
  echo -e "${COLOR_BLUE}Info: ${COLOR_NONE}$1"
}

success() {
  echo -e "${COLOR_GREEN}$1${COLOR_NONE}"
}

preinstall_apt_packages() {
  title "Install apt packages"

  sudo apt install -y \
  git-flow \
  zsh \
  neovim \
  curl \
  wget \
  trash-cli \
  direnv \
  tmux \
  docker.io \
  docker-doc \
  docker-compose \
  containerd \
  runc \
  apt-transport-https \
  build-essential \
  auditd \
  nasm \
  pkg-config \
  libfuse-dev \
  libssl-dev \
  qemu-system \
  qemu-system-common \
  qemu-utils \
  xsel \
  xclip
  sudo ubuntu-drivers install
}

setup_apt_package_list() {
  title "Configuring apt package list"

  if [ ! -e /etc/apt/sources.list.d/1password.list ]; then
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | sudo tee /etc/apt/sources.list.d/1password.list
    sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
    sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
  fi

  if [ ! -e /etc/apt/sources.list.d/wezterm.list ]; then
    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
    echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
  fi

  if [ ! -e /etc/apt/sources.list.d/github-cli.list ]; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  fi

  #初回は必ず更新
  if [ ! -e update-time ]; then
    sudo apt update
    sudo apt -y upgrade
    touch update-time
    date "+%s" > update-time
  else
    # 1日以上更新してなかったら更新
    now=$(date "+%s")
    updated=$(cat update-time)
    if [ $(($now-$updated)) -gt 86400 ]; then
      sudo apt update
      sudo apt -y upgrade
      date "+%s" > update-time
    fi
  fi
  sudo apt update
}

install_apt_packages() {
  title "Install apt packages"

  if ! command -v google-chrome-stable > /dev/null 2>&1 && $GRAPHICAL_TARGET; then
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    xdg-settings set default-web-browser google-chrome.desktop
  fi

  if ! command -v gh > /dev/null 2>&1 && $GRAPHICAL_TARGET; then
    sudo apt install gh
  fi

  if ! command -v op > /dev/nuill 2>&1; then
    sudo apt install 1password-cli
  fi
  sudo apt install 1password
}

install_packages() {
  title "Install packages"

  if ! command -v rustup > /dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source "$HOME/.cargo/env"
    rustup self update
    rustup update
  fi

  if ! command -v starship > /dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://starship.rs/install.sh | sudo sh -s -- -y
  fi

  if ! command -v sheldon > /dev/null 2>&1; then
    cargo install sheldon
    sheldon init --shell zsh
  fi

  if ! command -v exa > /dev/null 2>&1; then
    cargo install exa
  fi

  if [ ! -e $HOME/.local/share/fonts ] && $GRAPHICAL_TARGET; then
    curl -LO https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip?_gl=1*1dr4b*_ga*NDk1OTU5MzQwLjE2OTI2NjgxMDk.*_ga_9J976DJZ68*MTY5Mjc3MjkyMi4zLjAuMTY5Mjc3MjkyMy4wLjAuMA..&_ga=2.126337485.1528031180.1692772923-495959340.1692668109
    mkdir ~/.local/share/fonts
    unzip JetBrainsMono-2.304.zip -d ~/.local/share/fonts
    rm JetBrainsMono-2.304.zip
    fc-cache -fv
  fi
}

setup_desktop() {
  title "Setup Desktop settings"

  if $GRAPHICAL_TARGET; then
    LANG=C xdg-user-dirs-gtk-update

    gsettings set org.gnome.desktop.session idle-delay 0
    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
    gsettings set org.gnome.shell favorite-apps "['google-chrome.desktop', 'firefox_firefox.desktop', 'org.gnome.Nautilus.desktop', 'org.wezfurlong.wezterm.desktop']"
  fi
}

setup_symlinks() {
  title "Creating symlinks"

  for f in $(find home/.config -mindepth 1 -maxdepth 1); do
    ln  -snfv ${PWD}/"$f" ~/.config/
  done
  for f in $(find home/.local -mindepth 1 -maxdepth 1); do
    ln -snfv ${PWD}/"$f" ~/.local/
  done
  for f in $(find home/ -mindepth 1 -maxdepth 1 -path "home/.config" -prune -o -path "home/.local" -prune -o -print); do
    ln  -snfv ${PWD}/"$f" ~/
  done
  cat op.env | op inject > $HOME/.env
}

install_jetbrains_toolbox() {
  title "Install Jetbrains toolbox"
  if [ ! -e $HOME/.local/share/JetBrains ] && $GRAPHICAL_TARGET; then
    wget "https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.0.2.16660.tar.gz?_gl=1*1j86l66*_ga*MTM0MDYwODEwMS4xNjkyMDY4MzM3*_ga_9J976DJZ68*MTY5MjA2ODMzNy4xLjEuMTY5MjA2ODQ5Mi4wLjAuMA.." -O jetbrains-toolbox.tar.gz
    tar xzvf jetbrains-toolbox.tar.gz
    cd jetbrains-toolbox-2.0.2.16660
    ./jetbrains-toolbox
    cd ..
    rm -rfv jetbrains-toolbox*
  fi
}

update_command_alternative() {
  title "Update command alternative"

  if $GRAPHICAL_TARGET; then
    sudo update-alternatives --set x-terminal-emulator /usr/bin/open-wezterm-here
  fi
  sudo update-alternatives --set vi /usr/bin/nvim
  sudo update-alternatives --set vim /usr/bin/nvim
}

setup_shell() {
  title "Configuring shell"
  zsh_path=$(which zsh)

  if [[ "$SHELL"  != "$zsh_path" ]]; then
    chsh -s "$zsh_path"
    info "default shell changed to $zsh_path"
  fi
  sudo systemctl enable docker
  sudo usermod -aG docker $USER
  rm -rf ~/.bash*
}

echo -e
success "Start orchestrating dotfiles settings."

preinstall_apt_packages
setup_apt_package_list
install_apt_packages
install_packages
setup_desktop
setup_symlinks
install_jetbrains_toolbox
update_command_alternative
setup_shell

echo -e
success "Fin."
