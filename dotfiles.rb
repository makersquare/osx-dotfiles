#!/usr/bin/env ruby

require 'fileutils'
require 'mkmf'

USERNAME = `whoami`.chomp
HOME_DIR = File.expand_path('~/')
DOT_DIR = File.expand_path('~/.mks-dotfiles')
MKS_DIR = File.expand_path('~/code/mks')
DOT_FILES = ['.gitignore', '.gitconfig', '.zshrc']
BREW_ZSH = '/usr/local/bin/zsh'


# this is for the purpose of hiding the username with the oh-my-zsh powerline theme
# see agnoster theme: https://github.com/robbyrussell/oh-my-zsh/wiki/themes
def set_default_user
  open("#{HOME_DIR}/.zshrc", 'a') do |f|
    f.puts "DEFAULT_USER=#{USERNAME}"
  end
end

#prompt the user for git user name and password and set them globally
def get_git_info
  puts "Input the email address to use with Git"
  git_email = gets.chomp

  puts "Input your full name for use with Git"
  git_name = gets.chomp

  %x( git config --global user.name "#{git_name}" )
  %x( git config --global user.email #{git_email} )
end

# backup old dotfiles, symlink new dotfiles to ~/
def dot_file_replace
  DOT_FILES.each do |dot_file|
    dot_file_location = File.expand_path("~/#{dot_file}")
    unless File.exists?(dot_file_location)
      # symlink the file from DOT_DIR to HOME_DIR
      FileUtils.ln_s("#{DOT_DIR}/home/#{dot_file}", dot_file_location)
    else
      # move file to ~/.mks-dotfiles/backups/timestamp
      backup_dir = "#{DOT_DIR}/backups/#{Time.now.strftime("%Y%m%d")}"
      FileUtils.mkdir_p(backup_dir) unless File.exists?(backup_dir)
      FileUtils.mv(dot_file_location, backup_dir) unless File.exists?("#{backup_dir}/#{dot_file}")
      FileUtils.ln_sf("#{DOT_DIR}/home/#{dot_file}", dot_file_location)
    end
  end
end

# Create 'subl' shortcut for ST2 or ST3
def check_subl
  unless find_executable('subl')
    FileUtils.mkdir("#{HOME_DIR}/bin") unless File.exists?("#{HOME_DIR}/bin")
    if File.exists?("/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl")
      FileUtils.ln_sf("/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl", "#{HOME_DIR}/bin/subl")
    elsif File.exists?("/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl")
      puts "Sublime Text 3 not installed, creating shortcut to Sublime Text 2 instead"
      FileUtils.ln_sf("/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl", "#{HOME_DIR}/bin/subl")
    else
      puts "No Sublime Text versions installed, install Sublime Text and re-run this script to create the shortcut"
    end
  end
end

def check_ohmyzsh
  unless File.exists?(File.expand_path('~/.oh-my-zsh'))
    `git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh`
  else
    Dir.chdir(File.expand_path('~/.oh-my-zsh'))
    `git stash`
    `git pull --rebase --stat origin master`
    Dir.chdir(HOME_DIR)
  end
end

def check_zsh
  shell = `echo $SHELL`.chomp
  unless shell == BREW_ZSH
    shell_list = File.readlines("/etc/shells")
    unless shell_list.include?(BREW_ZSH) || shell_list.include?(BREW_ZSH+"\n")
      sudo "/bin/sh", "-c", "echo #{BREW_ZSH} >> /etc/shells"
    end
    %x( chsh -s #{BREW_ZSH} )
  end
end

# borrowed from the homebrew setup script
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

def ohai(*args)
  puts "#{Tty.blue}==>#{Tty.white} #{args.shell_s}#{Tty.reset}"
end

def warn(warning)
  puts "#{Tty.red}Warning#{Tty.reset}: #{warning.chomp}"
end

def system(*args)
  abort "Failed during: #{args.shell_s}" unless Kernel.system(*args)
end

def sudo(*args)
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

# get user confirmation before continuing
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

abort "Sorry, we currently only support Mac OSX 10.7 and higher" if macos_version < "10.7"
abort "Don't run this script with sudo!" if Process.uid == 0

ohai "This script will setup your local development environment"
puts "Creating ~/code/mks directory"

FileUtils.mkdir_p(MKS_DIR) unless File.exists?(MKS_DIR)

ohai "This script will now attempt to setup your shell configuration."
puts "Only attempt this step if you're connected to the internet."
wait_for_user

#check for existence of ~/.mks-dotfiles
unless File.exists?(DOT_DIR)
  # git clone dotfiles
  `git clone https://github.com/makersquare/osx-dotfiles ~/.mks-dotfiles`


  #do something with old .gitignore/.gitconfig/.zshrc
  #if there are existing dotfiles, move them to ~/.mks-dotfiles/backup/timestamp
  dot_file_replace

  FileUtils.ln_sf("#{DOT_DIR}/Vagrantfile", "#{MKS_DIR}/Vagrantfile")

  #add DEFAULT_USER to .zshrc
  set_default_user

  #get git email and name
  get_git_info

  #add homebrew zsh to /etc/shells
  check_zsh

  check_ohmyzsh

  # set their subl settings
  check_subl
  # set their powerline font

  # set the shell
  %x( chsh -s #{BREW_ZSH} )
  ohai "Congratulations, you're all finished! Open a new shell window to see what we've accomplished!"
else
  Dir.chdir(DOT_DIR)
  `git stash`
  `git pull --rebase origin master`

  # check for symlinks and repair if missing now
  dot_file_replace
  # add DEFAULT_USER to .zshrc again
  set_default_user
  # ask for git user name and password
  get_git_info
  # check for subl, add it if it doesn't exist
  check_subl
  # check that the user is using brew zsh, change if not
  check_zsh
  # check that oh_my_zsh exists, change if not
  check_ohmyzsh
end


