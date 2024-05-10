export PATH=~/.rd/bin:$PATH
export PATH=~/.local/bin:$PATH
export PATH=/opt/homebrew/bin:$PATH

function is_dirty() {
  local dotfiles_dir=~/dotfiles
  test -n "$(git -C ${dotfiles_dir} status --porcelain)" ||
    ! git diff --exit-code --stat --cached origin/main > /dev/null
}

function warn_dirty() {
  local dotfiles_dir=~/dotfiles
  if is_dirty $? ; then
    echo -e "\e[1;36m[[dotfiles]]\e[m"
    echo -e "\e[1;33m[warn] DIRTY DOTFILES\e[m"
    echo -e "\e[1;33m    -> Push your local changes in $dotfiles_dir\e[m"
  fi
}

if [ -e "${HOME}/.zshrc.secret" ]; then
  source "${HOME}/.zshrc.secret"
fi

if [ $SHLVL = 1 ]; then
  if [[ ! -o login ]]; then
    warn_dirty
  fi
  tmux
else
  export LANG=ja_JP.utf8
  export LANGUAGE=ja_JP.utf8
  export LC_ALL=ja_JP.utf8
  export PATH="$HOME/.cargo/bin:$PATH"
  export PATH="$HOME/.yarn/bin:$PATH"
  eval "$(sheldon source)"
fi
