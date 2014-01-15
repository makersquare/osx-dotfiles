$ar_databases = ['activerecord_unittest', 'activerecord_unittest2']
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
  exec { 'apt-get -y update' }
}
class { 'apt_get_update':
  stage => preinstall
}

# --- SQLite -------------------------------------------------------------------

package { ['sqlite3', 'libsqlite3-dev']:
  ensure => installed;
}

# --- PostgreSQL ---------------------------------------------------------------

class install_postgres {
  class { 'postgresql': }

  class { 'postgresql::server': }

  pg_database { $ar_databases:
    ensure   => present,
    encoding => 'UTF8',
    require  => Class['postgresql::server']
  }

  pg_user { 'rails':
    ensure  => present,
    require => Class['postgresql::server']
  }

  pg_user { 'vagrant':
    ensure    => present,
    superuser => true,
    require   => Class['postgresql::server']
  }

  package { 'libpq-dev':
    ensure => installed
  }

  package { 'postgresql-contrib':
    ensure  => installed,
    require => Class['postgresql::server'],
  }
}
class { 'install_postgres': }

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

# Nokogiri dependencies.
package { ['libxml2', 'libxml2-dev', 'libxslt1-dev']:
  ensure => installed
}

# ExecJS runtime.
package { 'nodejs':
  ensure => installed
}

# --- ZSH ---------------------------------------------------------------------

# This should be moved into a module

package { 'zsh':
  ensure => installed
}

file_line { 'add zsh to /etc/shells':
  path => '/etc/shells',
  line => '/usr/bin/zsh',
  require => Package['zsh'],
}

user { 'vagrant':
  ensure => present,
  shell => "/usr/bin/zsh",
  require => File_line['add zsh to /etc/shells'],
}

exec { 'install_oh_my_zsh':
  command => "curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh",
  creates => "${home}/.oh-my-zsh/oh-my-zsh.sh",
  require => [File_line['add zsh to /etc/shells'], Package['curl']]
}

#Note: I need to have a .zshrc file for them to use that specifies the options we want (i.e. turn off auto correct) and also has rbenv in the path for below

# --- Ruby ---------------------------------------------------------------------

class { 'rbenv': install_dir => '${home}/.rbenv' }

rbenv::plugin { ['sstephenson/ruby-build', 'rkh/rbenv-update', 'sstephenson/rbenv-gem-rehash']: }
rbenv::build { '2.1.0': global => true }
rbenv::gem { 'bundle': ruby_version => '2.1.0' }
