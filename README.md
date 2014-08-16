# VirtualEnv Config


This allows you to easily jump from project to in different virtual environments even easier. All credit is due to the infamous [Dan Sackett](https://github.com/dansackett) whom I forked this from and revised for my own use.


# Usage

Create an environment and work on it

    $ mkvirtualenv <name>
    
Deactivate a virtual environment

    $ deactivate
    
Work on a virtual environment

    $ workon <name>

# Installation

### 1: Install Packages
Install Python PIP (Package Manager) if not already installed.

    sudo apt-get install python-setuptools
    sudo easy_install pip

Globally Install our two items

    sudo pip install virtualenv virtualenvwrapper


### 2: Centralize the VirtualEnv settings

    mkdir ~/.virtualenvs
    echo "export WORKON_HOME=~/.virtualenvs" >> ~/.bashrc
    echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc
    echo "export PIP_VIRTUALENV_BASE=~/.virtualenvs" >> ~/.bashrc

### 3: Alias Creation

    echo "alias mkvirtualenv='mkvirtualenv --no-site-packages --distribute'" >> ~/.bashrc

And Reload!

    source ~/.bashrc

### 4: Setup VirtualEnv Hooks 

Edit your postactivate file (**~/.virtualenvs/postactivate**):

    # source postactivate hook
    _HOOK_PATH=bin/postactivate
    _PROJECT_FILE=$VIRTUAL_ENV/$VIRTUALENVWRAPPER_PROJECT_FILENAME

    if [ -s $_PROJECT_FILE ]; then
        export _PROJECT_DIR=$(cat $_PROJECT_FILE)
        _HOOK=$_PROJECT_DIR/$_HOOK_PATH
        [ -f $_HOOK ] && . $_HOOK
    fi

Your postdeactivate file (**~/.virtualenvs/postdeactivate**):

    # source postdeactivate hook
    _HOOK_PATH=bin/postdeactivate

    if [ -n "$_PROJECT_DIR" ]; then
        _HOOK=$_PROJECT_DIR/$_HOOK_PATH
        [ -f $_HOOK ] && . $_HOOK
        unset _PROJECT_DIR
    fi

Your postmkvirtualenv file (**~/.virtualenvs/postmkvirtualenv**):

**NOTE: If you are not storing files in `~/projects/` Then change it here!**

    #!/bin/bash
    # This hook is run after a new virtualenv is activated.

    proj_name=$(echo $VIRTUAL_ENV|awk -F'/' '{print $NF}')
    [ ! -d ~/projects/$proj_name ] && mkdir -p ~/projects/$proj_name
    add2virtualenv ~/projects/$proj_name
    cd ~/projects/$proj_name

Your predeactivate file (**~/.virtualenvs/predeactivate**)::

    #!/bin/bash
    # This hook is run before every virtualenv is deactivated.

    cd
