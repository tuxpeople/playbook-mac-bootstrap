#!/bin/bash

function installcli() {
  # https://gist.github.com/ChristopherA/a598762c3967a1f77e9ecb96b902b5db
  echo "Update MacOS & Install Command Line Interface. If this fails, do it manually."
  sudo /usr/sbin/softwareupdate -l
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  sudo /usr/sbin/softwareupdate -ia
  rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  echo "Sleep 20"
  sleep 20
  xcode-select --install
}

# Sudo Magic :)
sudo -v

# Keep-alive: update existing `sudo` time stamp until we have finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

[ ! -d "/Library/Developer/CommandLineTools" ] && installcli

echo "Installing pip"
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && sudo python get-pip.py

echo "Ansible"
sudo python -m pip install ansible paramiko pyparsing

mkdir -p /tmp/git
git clone https://github.com/tuxpeople/ansible-mac-bootstrap.git /tmp/git

echo "Setting max open files"
cd /tmp/git
sudo cp files/system/limit.maxfiles.plist /Library/LaunchDaemons
sudo cp files/system/limit.maxproc.plist /Library/LaunchDaemons
sudo chown root:wheel /Library/LaunchDaemons/limit.maxfiles.plist
sudo chown root:wheel /Library/LaunchDaemons/limit.maxproc.plist
sudo launchctl load -w /Library/LaunchDaemons/limit.maxfiles.plist
sudo launchctl load -w /Library/LaunchDaemons/limit.maxproc.plist

echo ""
echo "1: Please log into Mac Appstore"
echo "2: cd /tmp/git"
echo "3: ./run.sh"
