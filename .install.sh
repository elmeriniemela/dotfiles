#!/usr/bin/bash


set -euxo pipefail


sudo pacman -S python-pip git python-distutils-extra --needed
git clone --bare git@github.com:elmeriniemela/dotfiles.git $HOME/.dotfiles
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles checkout
dotfiles config --local status.showUntrackedFiles no
dotfiles submodule update --init --recursive
cd .config/bootstrap-linux
sudo pip install -e .

rm -f ~/.bashrc
rm -f ~/.bash_profile
sudo rm -f /root/.bash_profile
sudo rm -f /root/.bashrc


# TODO: unroll these into direct 'pacman' and 'install' commands. and remove the functions from bootstrap-linux as they are executed only once during setup.
bootstrap-linux distro
bootstrap-linux laptop

