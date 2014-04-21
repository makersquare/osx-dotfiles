#!/bin/sh
{
  echo "This script will download and link your dotfiles for you."

  if [ ! -d ~/.mks-dotfiles ]; then
    mkdir ~/.mks-dotfiles
    git clone https://github.com/makersquare/osx-dotfiles.git ~/.mks-dotfiles

    echo "cleaning up old dotfiles"
    if [ -f ~/.gitignore ] || [ -h ~/.gitignore ]; then
      rm -f ~/.gitignore
    fi

    if [ -f ~/.gitconfig ] || [ -h ~/.gitconfig ]; then
      rm -rf ~/.gitconfig
    fi

    if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
      echo "existing .zshrc detected, renaming .old-zshrc"
      mv ~/.zshrc ~/.old-zshrc
    fi

    if [ -d ~/.homesick ]; then
      rm -rf ~/.homesick
    fi

    echo "symlinking dotfiles to your home directory"
    for f in ~/.mks-dotfiles/home/.[^.]*
    do
      ln -s "$f" "$HOME/${f##*/}"
    done

    echo "DEFAULT_USER=`whoami`" >> .zshrc

  else
    echo "updating Dotfiles"
    cd ~/.mks-dotfiles
    git stash
    git pull origin master
    cd ~
  fi

  if [ -d ~/code/mks ]; then
    mv ~/code/mks ~/code/mks_backup
  fi

  mkdir -p ~/code/mks/frontend
  mkdir ~/code/mks/backend
  mkdir ~/code/mks/misc

  cp ~/.mks-dotfiles/Vagrantfile ~/code/mks/Vagrantfile
}
