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

if [[ ! -o login ]]; then
  warn_dirty
fi
eval "$(sheldon source)"
