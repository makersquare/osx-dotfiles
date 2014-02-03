#!/bin/sh
{
  echo "This script will download and link your dotfiles for you."
  if [ ! -d ~/dotfiles ]; then
    mkdir ~/dotfiles
    git clone https://github.com/makersquare/osx-dotfiles.git ~/dotfiles

    for f in ~/dotfiles/home/.[^.]*
    do
      ln -s "$f" "$HOME/${f##*/}"
    done

  
  fi

  if [ ! -d ~/Library/Fonts ]; then
    mkdir -p ~/Library/Fonts

    if [ ! -f ~/Library/Fonts/Menlo-Powerline.otf ]; then
      echo "adding font
      curl https://gist.github.com/qrush/1595572/raw/417a3fa36e35ca91d6d23ac961071094c26e5fad/Menlo-Powerline.otf > ~/Library/Fonts/Menlo-Powerline.otf
    fi
  fi
}
