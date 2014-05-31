#!/usr/bin/env ruby

require 'fileutils'
require 'mkmf'

USERNAME = `whoami`.chomp
HOME_DIR = File.expand_path('~/')
DOT_DIR = File.expand_path('~/.mks-dotfiles')
MKS_DIR = File.expand_path('~/code/mks')
DOT_FILES = ['.gitignore', '.gitconfig', '.zshrc']

ohai "This script will setup your local development environment"
puts "Creating ~/code/mks directory"

FileUtils.mkdir_p(MKS_DIR) unless File.exists?(MKS_DIR)

ohai "This script will now attempt to setup your shell configuration."
puts "Only do this step if you're currently connected to the internet."
wait_for_user
#check for existence of ~/.mks-dotfiles
unless File.exists?(DOT_DIR)
  # git clone dotfiles
  `git clone https://github.com/makersquare/osx-dotfiles ~/.mks-dotfiles`

  unless File.exists?(File.expand_path('~/.oh-my-zsh'))
    `git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh`
  else
    Dir.chdir(File.expand_path('~/.oh-my-zsh'))
    `git pull --rebase --stat origin master`
    Dir.chdir(HOME_DIR)
  end

  #do something with old .gitignore/.gitconfig/.zshrc
  #if there are existing dotfiles, move them to ~/.mks-dotfiles/backup/timestamp
  dot_file_replace

  FileUtils.ln_sf("#{DOT_DIR}/Vagrantfile", "#{MKS_DIR}/Vagrantfile")

  #add DEFAULT_USER to .zshrc
  set_default_user

  #get git email and name
  get_git_info

  #add homebrew zsh to /etc/shells
  brew_zsh = `which zsh`.chomp
  sudo "/bin/sh", "-c", "echo #{brew_zsh} >> /etc/shells"

  # set their subl settings
  check_subl
  # set their powerline font

  # set the shell
  %x( chsh -s #{brew_zsh} )
  ohai "Congratulations, you're all finished! Open a new shell window to see what we've accomplished!"
else
  Dir.chdir(DOT_DIR)
  `git stash`
  `git pull --rebase origin master`

  set_default_user
  get_git_info
  dot_file_replace
  check_subl

  # add DEFAULT_USER to .zshrc again
  # ask for git user name and password
  # check for symlinks and repair if missing now
  # check for subl, add it if it doesn't exist
  # check that the user is using brew zsh, change if not
  # check that oh_my_zsh exists, change if not
end

def set_default_user
  open("#{HOME_DIR}/.zshrc", 'a') do |f|
    f.puts "DEFAULT_USER=#{USERNAME}"
  end
end

def get_git_info
  #prompt for git user name and password
  puts "Input the email address to use with Git"
  git_email = gets.chomp

  puts "Input your full name for use with Git"
  git_name = gets.chomp

  %x( git config --global user.name "#{git_name}" )
  %x( git config --global user.email #{git_email} )
end

def dot_file_replace
  DOT_FILES.each do |dot_file|
    unless File.exists?(File.expand_path("~/#{dot_file}"))
      # symlink the file from DOT_DIR to HOME_DIR
    else
      # move file to ~/.mks-dotfiles/backup/timestamp
    end
  end
end

def check_subl
  unless find_executable('subl')
    FileUtils.mkdir("#{HOME_DIR}/bin") unless File.exists?("#{HOME_DIR}/bin")
    if File.exists?("/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl")
      FileUtils.ln_s("/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl", "#{HOME_DIR}/bin/subl")
    elsif File.exists?("/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl")
      puts "Sublime Text 3 not installed, creating shortcut to Sublime Text 2 instead"
      FileUtils.ln_s("/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl", "#{HOME_DIR}/bin/subl")
    else
      puts "No Sublime Text versions installed, install Sublime Text and re-run this script to create the shortcut"
    end
  end
end


##################
# helper methods #
##################
module Tty extend self
  def blue; bold 34; end
  def white; bold 39; end
  def red; underline 31; end
  def reset; escape 0; end
  def bold n; escape "1;#{n}" end
  def underline n; escape "4;#{n}" end
  def escape n; "\033[#{n}m" if STDOUT.tty? end
end

class Array
  def shell_s
    cp = dup
    first = cp.shift
    cp.map{ |arg| arg.gsub " ", "\\ " }.unshift(first) * " "
  end
end

def ohai *args
  puts "#{Tty.blue}==>#{Tty.white} #{args.shell_s}#{Tty.reset}"
end

def warn warning
  puts "#{Tty.red}Warning#{Tty.reset}: #{warning.chomp}"
end

def system *args
  abort "Failed during: #{args.shell_s}" unless Kernel.system(*args)
end

def sudo *args
  ohai "/usr/bin/sudo", *args
  system "/usr/bin/sudo", *args
end

def getc
  system "/bin/stty raw -echo"
  if STDIN.respond_to?(:getbyte)
    STDIN.getbyte
  else
    STDIN.getc
  end
ensure
  system "/bin/stty -raw echo"
end

def wait_for_user
  puts
  puts "Press RETURN to continue or any other key to abort"
  c = getc
  # we test for \r and \n because some stuff does \r instead
  abort unless c == 13 or c == 10
end

module Version
  def <=>(other)
    split(".").map { |i| i.to_i } <=> other.split(".").map { |i| i.to_i }
  end
end

def macos_version
  @macos_version ||= `/usr/bin/sw_vers -productVersion`.chomp[/10\.\d+/].extend(Version)
end

# Invalidate sudo timestamp before exiting
at_exit { Kernel.system "/usr/bin/sudo", "-k" }

# The block form of Dir.chdir fails later if Dir.CWD doesn't exist which I
# guess is fair enough. Also sudo prints a warning message for no good reason
Dir.chdir "/usr"

####################################################################### script
abort "MacOS too old, see: https://github.com/mistydemeo/tigerbrew" if macos_version < "10.7"
abort "Don't run this script with sudo!" if Process.uid == 0

ohai "This script will install:"
puts "#{HOMEBREW_PREFIX}/bin/brew"
puts "#{HOMEBREW_PREFIX}/Library/..."
puts "#{HOMEBREW_PREFIX}/share/man/man1/brew.1"

chmods = %w( . bin etc include lib lib/pkgconfig Library sbin share var var/log share/locale share/man
             share/man/man1 share/man/man2 share/man/man3 share/man/man4
             share/man/man5 share/man/man6 share/man/man7 share/man/man8
             share/info share/doc share/aclocal ).
            map{ |d| "#{HOMEBREW_PREFIX}/#{d}" }.
            select{ |d| File.directory? d and (not File.readable? d or not File.writable? d or not File.executable? d) }
chgrps = chmods.reject{ |d| File.stat(d).grpowned? }

unless chmods.empty?
  ohai "The following directories will be made group writable:"
  puts(*chmods)
end
unless chgrps.empty?
  ohai "The following directories will have their group set to #{Tty.underline 39}admin#{Tty.reset}:"
  puts(*chgrps)
end

wait_for_user if STDIN.tty?

if File.directory? HOMEBREW_PREFIX
  sudo "/bin/chmod", "g+rwx", *chmods unless chmods.empty?
  sudo "/usr/bin/chgrp", "admin", *chgrps unless chgrps.empty?
else
  sudo "/bin/mkdir", HOMEBREW_PREFIX
  sudo "/bin/chmod", "g+rwx", HOMEBREW_PREFIX
  # the group is set to wheel by default for some reason
  sudo "/usr/bin/chgrp", "admin", HOMEBREW_PREFIX
end

sudo "/bin/mkdir", HOMEBREW_CACHE unless File.directory? HOMEBREW_CACHE
sudo "/bin/chmod", "g+rwx", HOMEBREW_CACHE

if macos_version >= "10.9"
  developer_dir = `/usr/bin/xcode-select -print-path 2>/dev/null`.chomp
  if developer_dir.empty? || !File.exist?("#{developer_dir}/usr/bin/git")
    ohai "Installing the Command Line Tools (expect a GUI popup):"
    sudo "/usr/bin/xcode-select", "--install"
    puts "Press any key when the installation has completed."
    getc
  end
end

ohai "Downloading and installing Homebrew..."
Dir.chdir HOMEBREW_PREFIX do
  if git
    # we do it in four steps to avoid merge errors when reinstalling
    system git, "init", "-q"
    system git, "remote", "add", "origin", "https://github.com/Homebrew/homebrew"

    args = git, "fetch", "origin", "master:refs/remotes/origin/master", "-n"
    args << "--depth=1" if ARGV.include? "--fast"
    system(*args)

    system git, "reset", "--hard", "origin/master"
  else
    # -m to stop tar erroring out if it can't modify the mtime for root owned directories
    # pipefail to cause the exit status from curl to propogate if it fails
    # we use -k for curl because Leopard has a bunch of bad SSL certificates
    curl_flags = "fsSL"
    curl_flags << "k" if macos_version <= "10.5"
    system "/bin/bash -o pipefail -c '/usr/bin/curl -#{curl_flags} https://github.com/Homebrew/homebrew/tarball/master | /usr/bin/tar xz -m --strip 1'"
  end
end

warn "#{HOMEBREW_PREFIX}/bin is not in your PATH." unless ENV['PATH'].split(':').include? "#{HOMEBREW_PREFIX}/bin"


