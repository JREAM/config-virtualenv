#!/bin/bash

#1: Install Packages
sudo apt-get install python-setuptools
sudo easy_install pip
sudo pip install virtualenv virtualenvwrapper

#2: Centralize the VirtualEnv settings
mkdir -p ~/.virtualenvs
echo "export WORKON_HOME=~/.virtualenvs" >> ~/.bashrc
echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc
echo "export PIP_VIRTUALENV_BASE=~/.virtualenvs" >> ~/.bashrc

# 3: Alias Creation
echo "alias mkvirtualenv='mkvirtualenv --no-site-packages --distribute'" >> ~/.bashrc
source ~/.bashrc

# 4: Setup VirtualEnv Hooks (This clears out old settings)
cp templates/_postactivate ~/.virtualenvs/postactivate
cp templates/_postdeactivate ~/.virtualenvs/postdeactivate
cp templates/_postmkvirtualenv ~/.virtualenvs/postmkvirtualenv
cp templates/_predeactivate ~/.virtualenvs/predeactivate



