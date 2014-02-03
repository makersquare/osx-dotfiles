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
      rm -f ~/Library/Application\ Support/Sublime\ Text\ 2/Packages/User/Preferences.sublime-settings
      ln -s ~/dotfiles/Preferences.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 2/Packages/User/Preferences.sublime-settings
      git clone https://github.com/makersquare/flatland-mks.git ~/Library/Application\ Support/Sublime\ Text\ 2/Packages/flatland-mks
    elif [ -f /Applications/Sublime\ Text\ 3.app/Contents/SharedSupport/bin/subl ]; then
      echo "Creating subl link to Sublime Text 3"
      ln -s /Applications/Sublime\ Text\ 3.app/Contents/SharedSupport/bin/subl ~/bin/subl
      rm -f ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings
      ln -s ~/dotfiles/Preferences.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings
      git clone https://github.com/makersquare/flatland-mks.git ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/flatland-mks
    elif [ -f /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl ]; then
      echo "Creating subl link to Sublime Text"
      ln -s /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl ~/bin/subl
      rm -f ~/Library/Application\ Support/Sublime\ Text/Packages/User/Preferences.sublime-settings
      ln -s ~/dotfiles/Preferences.sublime-settings ~/Library/Application\ Support/Sublime\ Text/Packages/User/Preferences.sublime-settings
      git clone https://github.com/makersquare/flatland-mks.git ~/Library/Application\ Support/Sublime\ Text/Packages/flatland-mks
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

  if [ -d ~/code ]; then
    mv ~/code ~/old_code_backup
  fi
  mkdir ~/code
  mkdir ~/code/frontend
  mkdir ~/code/backend
  mkdir ~/code/misc

  cp ~/dotfiles/Vagrantfile ~/code/Vagrantfile
}
