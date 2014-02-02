#!/bin/sh
{
  echo "This script will download and link your dotfiles for you."
  if [ ! -d "~/dotfiles" ]; then
    mkdir ~/dotfiles
    git clone https://github.com/makersquare/osx-dotfiles.git ~/dotfiles

    for f in ~/dotfiles/home/.[^.]*
    do
      ln -s "$f" "$HOME/${f##*/}"
    done
  fi
  
  if [ ! -d "~/bin" ]; then
    mkdir ~/bin
    ln -s "/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl" ~/bin/subl
  fi
}
