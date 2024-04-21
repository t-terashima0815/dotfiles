#!/usr/bin/env bash

DOTFILES="$(pwd)"
COLOR_GRAY="\033[1;38;5;243m"
COLOR_BLUE="\033[1;34m"
COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"
COLOR_PURPLE="\033[1;35m"
COLOR_YELLOW="\033[1;33m"
COLOR_NONE="\033[0m"

if [ "$(uname)" == "Darwin" ]; then
  OS='Mac'
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  OS='Linux'
fi

title() {
  echo -e "\n${COLOR_PURPLE}$1${COLOR_PURPLE}"
  echo -e "${COLOR_GRAY}=================================${COLOR_NONE}\n"
}

install_packages() {
  if [ "$OS" == "Mac" ]; then
    brew install \
      asdf \
      neovim \
      1password-cli \
      tmux \
      direnv
    brew install --cask \
      google-chrome \
      1password \
      jetbrains-toolbox \
      karabiner-elements \
      wezterm
  elif [ "$OS" == "Linux" ]; then
    echo 'Linux'
  else
    echo 'Not Supported'
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
  for f in $(find home -mindepth 1 -maxdepth 1 -path "home/.config" -prune -o -path "home/.local" -prune -o -print); do
    ln  -snfv ${PWD}/"$f" ~
  done
  cat op.env | op inject > $HOME/.env
}

setup_rust_packages() {
  if ! command -v rustup > /dev/null 2>&1; then
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
      source "$HOME/.cargo/env"
      rustup self update
      rustup update
    fi

    mkdir -p ~/.local/bin
    if ! command -v starship > /dev/null 2>&1; then
      curl --proto '=https' --tlsv1.2 -sSf https://starship.rs/install.sh | sh /dev/stdin -f -b $HOME/.local/bin
    fi

    if ! command -v sheldon > /dev/null 2>&1; then
      cargo install sheldon
      sheldon init --shell zsh
    fi

    if ! command -v exa > /dev/null 2>&1; then
      cargo install exa
    fi
}

setup_font() {
    if [ ! -e $HOME/.local/share/fonts ] ; then
      curl -LO https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip?_gl=1*1dr4b*_ga*NDk1OTU5MzQwLjE2OTI2NjgxMDk.*_ga_9J976DJZ68*MTY5Mjc3MjkyMi4zLjAuMTY5Mjc3MjkyMy4wLjAuMA..&_ga=2.126337485.1528031180.1692772923-495959340.1692668109
      mkdir ~/.local/share/fonts
      unzip JetBrainsMono-2.304.zip -d ~/.local/share/fonts
      rm JetBrainsMono-2.304.zip
      fc-cache -fv
    fi
}

install_packages
setup_rust_packages
setup_font
setup_symlinks
