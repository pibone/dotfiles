#!/usr/bin/env bash

CONFIG_FOLDERS=("nvim" "zsh" "git" "starship.toml")
BCK=_bck
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

RED="\033[0;31m"
YELLOW="\033[1;33m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
NC="\033[0m"


# Config values
INSTALL="0"
CREATE_LINKS="0"

# parse args for config values
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -i|--install)
      INSTALL="1"
      shift # past argument
      ;;
    -l|--link)
      CREATE_LINKS="1"
      shift # past argument
      ;;
    -d|--default)
      INSTALL="1"
      CREATE_LINKS="1"
      shift # past argument
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

# main function
main() {
  [ $INSTALL == "1" ] && brew_install
  [ $CREATE_LINKS == "1" ] && create_links
}

brew_install() {
  command -v brew &> /dev/null && bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  TERMINAL="jq bat exa neovim micro git git-lfs ripgrep zsh httpie\
      fd cmake ack fzf yq tree coreutils wget mtr hub openssl pcre tmux\
      starship yarn cloc node@16 python3 sonarqube pass vivid zsh-completion bash-completion"
  DEVOPS="awscli kops terraform"
  CONTAINER="colima docker nerdctl lazydocker"
  K8S="kubectl k9s skaffold helm"
  COMPAT="ntfs-3g"
  DEV_LANGS="python3 ipython node@16 go sonarqube rustup-init"
  CASK="keka krita inkscape gimp iterm2 staruml slack \
      telegram-desktop sequel-pro visual-studio-code  \
      google-chrome firefox alfred secure-pipes       \
      font-fira-code-nerd-font font-fira-mono-nerd-font\
      macdown authy vimr rancher lens"

  brew install $TERMINAL $DEVOPS $CONTAINER $K8S $COMPAT $DEV_LANGS $CASK
}

create_links() {
  printf "Creating config links...\n"

  for folder in "${CONFIG_FOLDERS[@]}"; do
    link_folder $SCRIPT_DIR $XDG_CONFIG_HOME $folder
  done

  link_folder $XDG_CONFIG_HOME/zsh $HOME ".zshenv"

  printf "${GREEN}DONE${NC} creating config links.\n"
}

link_folder() {
  FROM=$1; TO=$2; FOLDER=$3;
  printf "Linking <$YELLOW$TO/$FOLDER$NC>... "
  [ -L $TO/$FOLDER ] && rm -f $TO/$FOLDER
  [ -d $TO/$FOLDER ] || [ -f $TO/$FOLDER ] && mv $TO/$FOLDER{,$BCK}
  ln -s {$FROM,$TO}/$FOLDER
  printf "${GREEN}DONE${NC}\n"
}

unlink_folder() {
  printf "Unlinking <$YELLOW$TO/$FOLDER$NC>... "
  FROM=$1; FOLDER=$3;
  [ -L $FROM/$FOLDER ] && rm -f $FROM/$FOLDER
  [ -d $FROM/$FOLDER$BCK ] || [ -f $FROM/$FOLDER$BCK ] && mv $FROM/$FOLDER{$BCK,}
  printf "${GREEN}DONE${NC}\n"
}

main
