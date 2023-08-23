#!/usr/bin/env bash

DOTFILES="$(pwd)"
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

  sudo apt install \
  zsh \
  neovim \
  curl \
  wget \
  apt-transport-https \
  build-essential \
  pkg-config \
  libfuse-dev \
  libssl-dev
}

setup_apt_package_list() {
  title "Configuring apt package list"

  if [ ! -n /etc/apt/sources.list.d/google-chrome.list ]; then 
    wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor > packages.google.gpg
    sudo install -o root -g root -m 644 packages.google.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.google.gpg] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
    rm packages.google.gpg
  fi

  sudo apt update
  sudo apt upgrade
}

install_apt_packages() {
  title "Install apt packages"

  if ! command -v google-chrome-stable > /dev/null 2>&1 ; then
    sudo apt install google-chrome-stable
    xdg-settings set default-web-browser google-chrome.desktop
  fi
}

install_packages() {
  title "Install packages"

  if ! command -v rustup > /dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    rustup self update
    rustup update
  fi

  if ! command -v starship > /dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://starship.rs/install.sh | sh -s -- -y
  fi

  if ! command -v sheldon > /dev/null 2>&1; then
    cargo install sheldon
    sheldon init --shell zsh
  fi

  if ! command -v exa > /dev/null 2>&1; then
    cargo install exa
  fi

  if ! command -v wezterm > /dev/null 2>&1; then
    curl -LO https://github.com/wez/wezterm/releases/download/20230712-072601-f4abf8fd/wezterm-20230712-072601-f4abf8fd.Ubuntu22.04.deb
    sudo apt install -y ./wezterm-20230712-072601-f4abf8fd.Ubuntu22.04.deb
    rm wezterm-20230712-072601-f4abf8fd.Ubuntu22.04.deb
  fi

  if [ ! -n $HOME/.local/share/fonts ]; then
    curl -LO https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip?_gl=1*1dr4b*_ga*NDk1OTU5MzQwLjE2OTI2NjgxMDk.*_ga_9J976DJZ68*MTY5Mjc3MjkyMi4zLjAuMTY5Mjc3MjkyMy4wLjAuMA..&_ga=2.126337485.1528031180.1692772923-495959340.1692668109
    mkdir ~/.local/share/fonts
    unzip JetBrainsMono-2.304.zip -d ~/.local/share/fonts
    rm JetBrainsMono-2.304.zip
  fi
}

setup_desktop() {
  title "Setup Desktop settings"

  LANG=C xdg-user-dirs-gtk-update

  gsettings set org.gnome.desktop.session idle-delay 0
  fc-cache -fv
}

setup_symlinks() {
  title "Creating symlinks"

  for f in $(find home/.config -mindepth 1 -maxdepth 1); do
    ln  -snfv ${PWD}/"$f" ~/.config/
  done
  for f in $(find home/ -mindepth 1 -maxdepth 1 -path "home/.config" -prune -o -print); do
    ln  -snfv ${PWD}/"$f" ~/
  done
}

install_jetbrains_toolbox() {
  title "Install Jetbrains toolbox"
  wget "https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.0.2.16660.tar.gz?_gl=1*1j86l66*_ga*MTM0MDYwODEwMS4xNjkyMDY4MzM3*_ga_9J976DJZ68*MTY5MjA2ODMzNy4xLjEuMTY5MjA2ODQ5Mi4wLjAuMA.." -O jetbrains-toolbox.tar.gz
  tar xzvf jetbrains-toolbox.tar.gz
  cd jetbrains-toolbox-2.0.2.16660
  ./jetbrains-toolbox
  cd ..
  rm -rfv jetbrains-toolbox*
}

update_command_alternative() {
  title "Update command alternative"

  sudo update-alternatives --config x-terminal-emulator
  sudo update-alternatives --config vi
  sudo update-alternatives --config vim
}

setup_shell() {
  title "Configuring shell"
  zsh_path=$(which zsh)

  if [[ "$SHELL"  != "$zsh_path" ]]; then
    chsh -s "$zsh_path"
    info "default shell changed to $zsh_path"
  fi
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
