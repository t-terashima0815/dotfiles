if [ "$(uname)" = "Darwin" ]; then
  OS='Mac'
fi

if [[ $(command -v exa) ]]; then
  alias e='exa --icons'
  alias l=e
  alias ls=e
  alias ea='exa -a --icons'
  alias la=ea
  alias ee='exa -aal --icons'
  alias ll=ee
  alias et='exa -T -L 3 -a -I "node_modules|.git|.cache" --icons'
  alias lt=et
  alias eta='exa -T -a -I "node_modules|.git|.cache" --icons | less -r'
  alias lta=eta
fi

if [[ $(command -v docker) ]]; then
  alias dl='echo $CR_PAT | docker login ghcr.io -u t-terashima0815 --password-stdin'
  alias dc='docker compose'
  if [ "$OS" = "Mac" ]; then
    alias dcr='dc run --platform linux/amd64'
    alias dr='docker run --platform linux/amd64'
    alias dcb='dc build --platform linux/amd64'
    alias dru='dr --env-file $HOME/.env -u 1000:1000'
    alias dre='dr --env-file $HOME/.env -e LOCAL_GID=1000 -e LOCAL_UID=1000'
  else
    alias dcr='dc run'
    alias dr='docker run'
    alias dcb='dc build'
    alias dru='dr --env-file $HOME/.env -u `id -u`:`id -g`'
    alias dre='dr --env-file $HOME/.env -e LOCAL_GID=$(id -g) -e LOCAL_UID=$(id -u)'
  fi
  alias php='dre -it -v $PWD:/app ghcr.io/old-home/php php'
  alias composer='dre -it -v $PWD:/app ghcr.io/old-home/php composer'
  alias phpdoc='dru --rm -v $PWD:/data phpdoc/phpdoc && sudo chown -R $(id -g):$(id -u) build'
  alias php-template='dre -it -v $PWD:/app -v $HOME/.ssh:/home/docker/.ssh ghcr.io/old-home/php composer create-project graywings/php-docker-template'
  alias php-template-dev='dre -it -v $PWD:/app -v $HOME/.ssh:/home/docker/.ssh ghcr.io/old-home/php composer create-project graywings/php-docker-template --stability=RC'
  alias serve='dre -it -v $PWD:/app -p 8000:8000 ghcr.io/old-home/php php artisan serve --host 0.0.0.0'
fi

function php-template() {
  docker run -v $PWD:/app composer composer create-project graywings/php-docker-template $1
  sudo chown -R $(whoami): $1
}
