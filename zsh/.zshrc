export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export ZDOTDIR=$XDG_CONFIG_HOME/zsh

CONFIG_HOME=$ZDOTDIR
DATA_HOME=$XDG_DATA_HOME/zsh
CACHE_HOME=$XDG_CACHE_HOME/zsh

FZF_DATA=/usr/local/opt/fzf

[ ! -d $DATA_HOME ] && mkdir -p $DATA_HOME
[ ! -d $CACHE_HOME ] && mkdir -p $CACHE_HOME

export ZSH_COMPDUMP=$CACHE_HOME/.zcompdump-$HOST
export HISTFILE="$DATA_HOME/zhistory"
export HISTSIZE=10000


path+=/usr/local/sbin
path+=/usr/local/bin
path+=$FZF_DATA/bin
path+=$HOME/.local/bin
path+=$HOME/bin
path+=$HOME/.cargo/bin
export PATH=$PATH


export KUBE_EDITOR=nvim
export EDITOR=nvim

fpath+=~/.zfunc
fpath+=$XDG_CONFIG_HOME/zsh/zfunc

# Autoload completion extensions
autoload -U compinit -d $ZSH_COMPDUMP && compinit -d $ZSH_COMPDUMP
autoload -U +X bashcompinit && bashcompinit

# ZSH plugins
plugins=(... docker)

# if command -v pass &> /dev/null; then
#   PASS_STORE=$HOME/.work-password-store
#   STORE_REPO_URL=git@github.com:PepperES/secrets-store.git
#   alias workpass="PASSWORD_STORE_DIR=$PASS_STORE pass"
#   if [[ ! -d $PASS_STORE ]]; then
#     echo "Cloning the workpass secret store"
#     git clone $STORE_REPO_URL $PASS_STORE
#   else
#     (set +m; git -C ${PASS_STORE} pull&) > /dev/null
#   fi
# fi

PREZTO_DATA="$DATA_HOME/zprezto"
if [[ ! -d $PREZTO_DATA ]]; then
  PREZTO_REPO="git@github.com:sorin-ionescu/prezto.git"
  PREZTO_CONTRIB_REPO="git@github.com:belak/prezto-contrib.git"
  echo "Cloning prezto data repository"
  git clone --recursive $PREZTO_REPO $PREZTO_DATA
  git clone --recursive $PREZTO_CONTRIB_REPO $PREZTO_DATA/contrib
else 
  source $PREZTO_DATA/init.zsh
fi

# starship prompt
source <(starship init zsh --print-full-init)

# completions
## kubectl
source <(kubectl completion zsh)
## flux
source <(flux completion zsh) && compdef _flux flux
## aws
complete -C '/usr/local/bin/aws_completer' aws

export LS_COLORS="$(vivid generate molokai)"

alias vi=nvim
alias vim=nvim
alias nano=micro
alias pico=micro
alias ls=exa
alias cat=bat
alias g=git
alias k=kubectl


[ -f $HOME/.zshrc ] && source $HOME/.zshrc

# Load fzf
if [[ -d $FZF_DATA ]]; then
  source "$FZF_DATA/shell/completion.zsh" 2> /dev/null
  source "$FZF_DATA/shell/key-bindings.zsh" 2> /dev/null
fi
