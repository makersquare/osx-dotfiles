class dotfiles {
  file { '/home/vagrant/.zshrc':
    ensure    => file,
    content   => template('dotfiles/.zshrc'),
    mode      => '0766'
  }

  file { '/home/vagrant/.rspec':
    ensure    => file,
    content   => template('dotfiles/.rspec'),
    mode      => '0766'
  }

  file { '/home/vagrant/.gemrc':
    ensure    => file,
    content   => template('dotfiles/.gemrc'),
    mode      => '0766'
  }

  file { '/home/vagrant/.vimrc':
    ensure    => file,
    content   => template('dotfiles/.vimrc'),
    mode      => '0766'
  }

  file { '/home/vagrant/.bundler/config':
    ensure    => file,
    content   => template('dotfiles/config'),
    mode      => '0766'
  }
}
