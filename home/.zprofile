function is_dirty() {
  local dotfiles_dir=~/dotfiles
  test -n "$(git -C ${dotfiles_dir} status --porcelain)" ||
    ! git -C ${dotfiles_dir} diff --exit-code --stat --cached origin/mac > /dev/null
}

function auto_sync() {
  local dotfiles_dir=~/dotfiles
  echo -e "\e[1;36m[[dotfiles]]\e[m"
  echo -e "\e[1;36mTry auto sync...\e[m"
  if (cd $dotfiles_dir && git pull && $dotfiles_dir/install.sh -l && cd $HOME); then
    if is_dirty $? ; then
      echo -e "\e[1;31m[Failed]\e[m"
      echo -e "\e[1;33m[Warn] DIRTY DOTFILES\e[m"
      echo -e "\e[1;33m    -> Push your local changes in $dotfiles_dir\e[m"
    else
      echo -e "\e[1;32m [Successed]\e[m"
    fi
  else
    echo -e "\e[1;31m [Failed]\e[m"
    echo -e "\e[1;33m[Warn] Could not pull remote changes.\e[m"
  fi
}

auto_sync
