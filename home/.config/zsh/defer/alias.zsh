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
  alias dcr='dc run'
  alias dcb='dc build'
  alias php-template='docker run -it -v $PWD:/app -e LOCAL_GID=$(id -g) -e LOCAL_UID=$(id -u) ghcr.io/old-home/php composer create-project graywings/php-docker-template'
  alias php='docker run -it -v $PWD:/app -e LOCAL_GID=$(id -g) -e LOCAL_UID=$(id -u) ghcr.io/old-home/php php'
  alias composer='docker run -it -v $PWD:/app -e LOCAL_GID=$(id -g) -e LOCAL_UID=$(id -u) ghcr.io/old-home/php composer'
  alias doxygen='docker run --rm -v "${PWD}":/data nakatt/doxygen Doxyfile'
fi

function php-template() {
  docker run -v $PWD:/app composer composer create-project graywings/php-docker-template $1
  sudo chown -R $(whoami): $1
}

alias rm=trash-put
