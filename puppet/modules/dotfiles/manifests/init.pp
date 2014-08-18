class dotfiles {
  file { '/home/vagrant/.zshrc':
    ensure    => file,
    content   => template('dotfiles/.zshrc'),
    mode      => '0766',
    owner => "vagrant",
    group => "vagrant"
  }

  file { '/home/vagrant/.rspec':
    ensure    => file,
    content   => template('dotfiles/.rspec'),
    mode      => '0766',
    owner => "vagrant",
    group => "vagrant"
  }

  file { '/home/vagrant/.gemrc':
    ensure    => file,
    content   => template('dotfiles/.gemrc'),
    mode      => '0766',
    owner => "vagrant",
    group => "vagrant"
  }

  file { '/home/vagrant/.vimrc':
    ensure    => file,
    content   => template('dotfiles/.vimrc'),
    mode      => '0766',
    owner => "vagrant",
    group => "vagrant"
  }

  file { '/home/vagrant/.bundle':
    ensure    => directory,
    owner => "vagrant",
    group => "vagrant"
  }

  file { '/home/vagrant/.bundle/config':
    ensure    => file,
    content   => template('dotfiles/config'),
    mode      => '0766',
    owner => "vagrant",
    group => "vagrant"
  }

  file { '/home/vagrant/.npmrc':
    ensure    => file,
    content   => template('dotfiles/.npmrc'),
    mode      => '0766',
    owner => "vagrant",
    group => "vagrant"
  }
}
