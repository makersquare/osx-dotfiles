#!/bin/sh
{
  echo "This script will download and link your dotfiles for you."

  if [ ! -d ~/dotfiles ]; then
    mkdir ~/dotfiles
    git clone https://github.com/makersquare/osx-dotfiles.git ~/dotfiles

    echo "cleaning up old dotfiles"
    if [ -f ~/.gitignore ]; then
      rm -f ~/.gitignore
    fi

    if [ -f ~/.gitconfig ]; then
      rm -rf ~/.gitconfig
    fi

    if [ -f ~/.zshrc ]; then
      echo "existing .zshrc detected, renaming .old-zshrc"
      mv ~/.zshrc ~/.old-zshrc
    fi

    echo "symlinking dotfiles to your home directory"
    for f in ~/dotfiles/home/.[^.]*
    do
      ln -s "$f" "$HOME/${f##*/}"
    done

  else
    echo "updating Dotfiles"
    git -C ~/dotfiles stash
    git -C ~/dotfiles pull origin master
  fi

  if [ ! -d ~/bin ]; then
    echo "Creating ~/bin"
    mkdir ~/bin
  fi

  if [ ! -f ~/bin/subl ]; then
    if [ -f /Applications/Sublime\ Text\ 2.app/Contents/SharedSupport/bin/subl ]; then
      echo "Creating subl link to Sublime Text 2"
      ln -s /Applications/Sublime\ Text\ 2.app/Contents/SharedSupport/bin/subl ~/bin/subl
    elif [ -f /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl ]; then
      echo "Creating subl link to Sublime Text"
      ln -s /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl ~/bin/subl
    else
      echo "Install Sublime Text first"
    fi
  fi

  if [ ! -d ~/Library/Fonts ]; then
    echo "making ~/Library/Fonts"
    mkdir -p ~/Library/Fonts

    if [ ! -f ~/Library/Fonts/Menlo-Powerline.otf ]; then
      echo "adding font for terminal"
      curl https://gist.github.com/qrush/1595572/raw/417a3fa36e35ca91d6d23ac961071094c26e5fad/Menlo-Powerline.otf > ~/Library/Fonts/Menlo-Powerline.otf
    fi
  else
    if [ ! -f ~/Library/Fonts/Menlo-Powerline.otf ]; then
      echo "adding font for terminal"
      curl https://gist.github.com/qrush/1595572/raw/417a3fa36e35ca91d6d23ac961071094c26e5fad/Menlo-Powerline.otf > ~/Library/Fonts/Menlo-Powerline.otf
    fi
  fi
}
