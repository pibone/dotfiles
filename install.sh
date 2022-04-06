brew_install() {
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  TERMINAL="jq bat exa neovim micro git git-lfs ripgrep zsh httpie\
      fd cmake ack fzf yq tree coreutils wget mtr hub openssl pcre tmux\
      starship yarn cloc node@16 python3 sonarqube pass"
  DEVOPS="awscli kops terraform"
  CONTAINER="colima docker nerdctl lazydocker"
  K8S="kubectl k9s skaffold helm"
  COMPAT="ntfs-3g fuse4x fuse4x-kext"
  DEV_LANGS="python3 ipython node@16 go sonarqube rustup-init"
  CASK="keka krita inkscape gimp iterm2 staruml slack \
      telegram-desktop sequel-pro visual-studio-code  \
      google-chrome firefox alfred secure-pipes       \
      font-fira-code-nerd-font font-fira-mono-nerd-font\
      macdown authy vimr"

  brew install $TERMINAL $DEVOPS $CONTAINER $K8S $COMPAT $DEV_LANGS $CASK
}

