#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
IFS=$'\n\t\v'
cd `dirname "${BASH_SOURCE[0]:-$0}"`

if [[ ! -d $HOME/.oh-my-zsh ]]; then
  # https://github.com/ohmyzsh/ohmyzsh#basic-installation
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [[ ! -d $HOME/.oh-my-zsh/custom/themes/powerlevel10k ]]; then
  # https://github.com/romkatv/powerlevel10k#oh-my-zsh
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

command -v xfce4-terminal > /dev/null || echo "WARN: xfce4-terminal is not installed"
command -v j4-dmenu-desktop > /dev/null || echo "WARN: j4-dmenu-desktop is not installed"

# https://developer.atlassian.com/blog/2016/02/best-way-to-store-dotfiles-git-bare-repo/

TMPDIR="/tmp/myconf-tmp"
rm -rf $TMPDIR

git clone --separate-git-dir=$HOME/.cfg https://github.com/Juravenator/dotfiles.git $TMPDIR
rsync -a $TMPDIR/ $HOME
rm -rf $TMPDIR

git --git-dir=$HOME/.cfg/ --work-tree=$HOME config status.showUntrackedFiles no