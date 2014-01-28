# A Virtual Machine for MakerSquare Student Development

## Introduction

This project automates the setup of a development environment for MakerSquare students. Use this virtual machine to work on a pull request with everything ready to hack and run the test suites.


## Requirements

* [VirtualBox](https://www.virtualbox.org)

* [Vagrant](http://vagrantup.com)

## How To Build The Virtual Machine

Building the virtual machine is this easy:

    host $ git clone https://github.com/makersquare/rails-dev-box.git
    host $ cd rails-dev-box
    host $ vagrant up

That's it.

If the base box is not present that command fetches it first. The setup itself takes about 3 minutes in my MacBook Air. After the installation has finished, you can access the virtual machine with

    host $ vagrant ssh
    Welcome to Ubuntu 12.04 LTS (GNU/Linux 3.2.0-23-generic-pae i686)
    ...
    vagrant@rails-dev-box:~$

Port 3000 in the host computer is forwarded to port 3000 in the virtual machine. Thus, applications running in the virtual machine can be accessed via localhost:3000 in the host computer.

## What's In The Box

* Git

* RBENV

* Ruby 2.1.0

* Bundler

* SQLite3 and Postgres

* System dependencies for nokogiri, sqlite3, and pg

* Databases and users needed to run the Active Record test suite

* Node.js for the asset pipeline

## Recommended Workflow

The recommended workflow is

* edit in the host computer and

* test within the virtual machine.

Just clone your Rails fork into the rails-dev-box directory on the host computer:

    host $ ls
    README.md   Vagrantfile puppet
    host $ git clone git@github.com:<your username>/rails.git

Vagrant mounts that directory as _/vagrant_ within the virtual machine:

    vagrant@rails-dev-box:~$ ls /vagrant
    puppet  rails  README.md  Vagrantfile

Install gem dependencies in there:

    vagrant@rails-dev-box:~$ cd /vagrant/rails
    vagrant@rails-dev-box:/vagrant/rails$ bundle

We are ready to go to edit in the host, and test in the virtual machine.

This workflow is convenient because in the host computer you normally have your editor of choice fine-tuned, Git configured, and SSH keys in place.

## Virtual Machine Management

When done just log out with `^D` and suspend the virtual machine

    host $ vagrant suspend

then, resume to hack again

    host $ vagrant resume

Run

    host $ vagrant halt

to shutdown the virtual machine, and

    host $ vagrant up

to boot it again.

You can find out the state of a virtual machine anytime by invoking

    host $ vagrant status

Finally, to completely wipe the virtual machine from the disk **destroying all its contents**:

    host $ vagrant destroy # DANGER: all is gone

Please check the [Vagrant documentation](http://docs.vagrantup.com/v2/) for more information on Vagrant.

## FAQ

### What is the purpose of Vagrant?
Best described in this response [here](http://www.reddit.com/r/rails/comments/1w7sid/whats_the_purpose_of_vagrant/).

### How would I build a new base box?

Check out this blog post [here](http://tylerbird.com/blog/2014/01/27/building-a-vagrant-box-from-start-to-finish/).

### I don't understand Puppet, what does it do?

Puppet allows you to script a reliable method of installing development dependencies on a system. This process is called provisioning. You can read more about how Puppet works [here](http://docs.puppetlabs.com/).

## Gratitude

Modified from the [Rails Dev Box](https://github.com/rails/rails-dev-box) provided by the Rails team.

## License

Released under the MIT License, Copyright (c) 2012–<i>ω</i> Xavier Noria.
