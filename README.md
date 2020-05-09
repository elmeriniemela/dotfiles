## dotfiles

### Installation

* `git clone --bare https://github.com/elmeriniemela/dotfiles.git $HOME/.dotfiles`
* `alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'`
* `dotfiles checkout`
* `dotfiles config --local status.showUntrackedFiles no`
