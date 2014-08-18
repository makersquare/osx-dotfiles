$as_vagrant   = 'sudo -u vagrant -H bash -l -c'
$home         = '/home/vagrant'

Exec {
  path => ['/usr/sbin', '/usr/bin', '/sbin', '/bin']
}

# --- Preinstall Stage ---------------------------------------------------------

stage { 'preinstall':
  before => Stage['main']
}

class apt_get_update {
  exec { 'apt-get -y update':
    unless => "test -e ${home}/.rbenv"
  }
}
class { 'apt_get_update':
  stage => preinstall
}

# --- SQLite -------------------------------------------------------------------

package { ['sqlite3', 'libsqlite3-dev']:
  ensure => installed;
}

# --- Packages -----------------------------------------------------------------

package { 'curl':
  ensure => installed
}

package { 'build-essential':
  ensure => installed
}

package { 'git-core':
  ensure => installed
}

package { 'vim':
  ensure => installed
}

#rmagick dependencies.
package { 'libmagickwand-dev':
  ensure => installed
}

package { 'imagemagick':
  ensure => installed
}

# Nokogiri dependencies.
package { ['libxml2', 'libxml2-dev', 'libxslt1-dev']:
  ensure => installed
}

# ExecJS runtime.
package { 'nodejs':
  ensure => installed,
  require => Apt::Ppa['ppa:chris-lea/node.js'],
}

package { 'zsh':
  ensure => installed
}

# --- Configuration Files ---------------------------------------------------------------------

class { 'dotfiles': }

# --- Ruby ---------------------------------------------------------------------

class { 'rbenv': install_dir => "${home}/.rbenv" }
#specify ruby version to be default
$rubyver = '2.0.0-p481'

#install rbenv plugins
rbenv::plugin { ['sstephenson/ruby-build', 'rkh/rbenv-update', 'sstephenson/rbenv-gem-rehash']: }

rbenv::build { $rubyver: global => true }
rbenv::gem { 'pry': ruby_version => $rubyver }
rbenv::gem { 'hirb': ruby_version => $rubyver }
rbenv::gem { 'mini_magick': ruby_version => $rubyver }
rbenv::gem { 'nokogiri': ruby_version => $rubyver }

# --- Node ---------------------------------------------------------------------

class { 'apt': }
apt::ppa { 'ppa:chris-lea/node.js': }

# directory for globally installed npm packages
file { "/home/vagrant/.local/":
  ensure => "directory",
  owner => "vagrant",
  group => "vagrant"
}


# --- Symlink Dir Creation -----------------------------------------------------

file { "/home/vagrant/code/":
    ensure => "directory",
    owner => "vagrant",
    group => "vagrant"
}

file { "/home/vagrant/code/mks/":
    ensure => "directory",
    owner => "vagrant",
    group => "vagrant"
}

# --- Zsh and Oh-My-Zsh ---------------------------------------------------------------------

class { 'ohmyzsh': }
ohmyzsh::install { 'vagrant': }

# --- Postgresql -----------------------------------------------------------------

class { 'postgresql::server': }

package { 'libpq-dev':
  ensure => installed,
  require   => Class['postgresql::server']
}
package { 'postgresql-contrib':
    ensure  => installed,
    require   => Class['postgresql::server']
}

postgresql::server::role { 'vagrant':
  # password_hash => postgresql_password('marmot', 'mypasswd'),
  createdb => true,
  require   => Class['postgresql::server']
}

postgresql::server::db { 'vagrant':
  user     => 'vagrant',
  encoding => 'UTF8',
  password => '',
  require   => Class['postgresql::server']
}
