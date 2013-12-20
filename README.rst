Dan's Django Setup
============

This is my ideal setup when dealing with Django and Python. A lot is borrowed
from work environments and others I have seen across the web. Feel free to use
some of it or all of it if you'd like.

Virtualenv and Virtualenv Wrapper
--------------------------------

It's important when working with Django to have an environment you can easily
reproduce. With Virtualenv you can isolate your environment on a per project
basis to make it easier to manage. Here's a good guide on getting that setup::

    sudo apt-get install python-setuptools
    sudo easy_install pip

Pip will allow you to manage your python packages easily. We'll use it to
install Virtualenv and virtualenvwrapper::

    sudo pip install virtualenv
    sudo pip install virtualenvwrapper

A practice I use at work is to keep the virtual environments in a central
location. I keep mine in the home root so we can do so with the following
commands::

    mkdir ~/.virtualenvs
    echo "export WORKON_HOME=~/.virtualenvs" >> ~/.bashrc
    echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc
    echo "export PIP_VIRTUALENV_BASE=~/.virtualenvs" >> ~/.bashrc

These steps will setup the virtualenv and virtualenvwrapper to work together.
We can do one last thing and add this line::

    echo "alias mkvirtualenv='mkvirtualenv --no-site-packages --distribute'" >> ~/.bashrc

This alias will allow you to easily create a new virtualenv with the command
mkvirtualenv without using site packages and using distribute instead of
setuptools.::

    source ~/.bashrc

That will reload the bash prompt and get everything ready to use. The next
thing I like to do is setup the virtualenv to work well with my current
projects folder. I use a projects folder in the home directory for my web work
and applications. Edit your postactivate file (**~/.virtualenvs/postactivate**)::

    # source postactivate hook
    _HOOK_PATH=bin/postactivate
    _PROJECT_FILE=$VIRTUAL_ENV/$VIRTUALENVWRAPPER_PROJECT_FILENAME

    if [ -s $_PROJECT_FILE ]; then
        export _PROJECT_DIR=$(cat $_PROJECT_FILE)
        _HOOK=$_PROJECT_DIR/$_HOOK_PATH
        [ -f $_HOOK ] && . $_HOOK
    fi

Your postdeactivate file (**~/.virtualenvs/postdeactivate**)::

    # source postdeactivate hook
    _HOOK_PATH=bin/postdeactivate

    if [ -n "$_PROJECT_DIR" ]; then
        _HOOK=$_PROJECT_DIR/$_HOOK_PATH
        [ -f $_HOOK ] && . $_HOOK
        unset _PROJECT_DIR
    fi

Your postmkvirtualenv file (**~/.virtualenvs/postmkvirtualenv**)::

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

After these are edited, you will be able to create a new virtualenv with
**mkvirtualenv project_name** and when you do a folder named **project_name**
will be created in ~/projects. You will automatically CD into that directory
and when you deactivate you will be placed back in your home folder. Pretty
neat.

Django
------

Django has many different ways to setup a project, but I've come to enjoy my current setup most of all.
It's what I use at work and at home now and seems to work for just about every project that I'm starting.


Main Directory Structure
^^^^^^^^^^^^^^^^^^^^^^^^

I did stop relying on django-admin.py startproject until I took the time to make a template for my projects which can be found here https://github.com/dansackett/django_template.
Here's my current setup though in terms of directories::
    
    apps
    bin
    project_name
    public
    reqs
    templates
    
Along with these main directories, I create these files::

    fabfile.py
    README.rst
    .gitignore
    
As you can see from the .gitignore file, I also instantiate a git repository with **git init**. Let me break
down each directory so you can get an idea of what lives where.

Apps Directory
^^^^^^^^^^^^^^

In apps, I place each of my applications. If I have an application for blog posts then I make a directory named
posts in the apps directory. This is common practice already. Within that, I setup the traditional files for an app::

    __init__.py
    models.py
    views.py
    urls.py
    forms.py
    
With these in place, I can now do what I need to in order to have a working application. 

Bin Directory
^^^^^^^^^^^^^

In the bin directory, I place scripts. My main ones are a postactivate and postdeactivate hook. I'll show you those.

postactivate::

    #!/bin/bash
    #
    # source this file from your virtualenv postactivate hook
    # eg:
    #    . /path/to/repo/bin/postactivate
    
    REPO_PATH="$( cd "$( dirname "$( dirname "${BASH_SOURCE[0]}" )" )" && pwd )"
    if [ "$PYTHONPATH" == "" ]; then
        export PYTHONPATH=$REPO_PATH:$REPO_PATH/apps
    else
        PYTHONPATH_OLD=$PYTHONPATH
        export PYTHONPATH=$REPO_PATH:$REPO_PATH/apps:$PYTHONPATH
    fi
    export DJANGO_SETTINGS_MODULE=project_name.settings
    
postdeactivate::
    
    #!/bin/bash
    #
    # source this file from your virtualenv postdeactivate hook
    # eg:
    #    . /path/to/repo/bin/postdeactivate
    
    if [ "$PYTHONPATH_OLD" == "" ]; then
        unset PYTHONPATH
    else
        export PYTHONPATH=$PYTHONPATH_OLD
        unset PYTHONPATH_OLD
    fi
    unset REPO_PATH
    unset DJANGO_SETTINGS_MODULE
    
In the instructions, it tells you to edit the hooks in the actual virtualenv. Basically what these files will do
is add the DJANGO_SETTINGS_MODULE to the path and point to the right places so you can use django-admin.py for all
Django commands rather than manage.py. In fact, I don't ever create a manage.py file anymore. To edit the virtualenv
items, use this shortcut::

    cdvirtualenv bin
    
You will then be in the virtualenv and able to edit the postactivate hook and the postdeactivate hook as the instructions
note. Use::

    cd -
    
To return to your project directory after editing.

Public Directory
^^^^^^^^^^^^^^^^

In the public directory, you will be setting up the following directories::

    css
    js
    img
    
These will contain your static and media files. 

Reqs Directory
^^^^^^^^^^^^^^

In here, we have three files::

    base.txt
    dev.txt
    prod.txt
    
Here is where you freeze the pip requirements so we can easily reproduce our environment. Going through some of the basics:

base.txt::

    Django
    MySQL-python
    South
    Fabric
    
These are essential for me as I use MySQL for the DB still (I know...), South for migrations, and Fabric for updating the server.

dev.txt::

    -r base.txt
    
    Werkzeug
    django-debug-toolbar
    django-extensions
    bpython
    
These are all meant for helping with debugging. bPython gives me a sweet python interface that Django Shell automatically
jumps into. The prod.txt file will depend on what you need outside of development. Mine sometimes stays blank.

To install these use::

    pip install -r dev.txt
    
Do this on the dev machine and prod.txt on the production. Since we include the base file in the dev/prod reqs documents
then they will also get installed with the environment stuff. Pretty neat.

Templates Directory
^^^^^^^^^^^^^^^^^^^

In here, I place all my templates in individual directories matching the app name. Like the blog application, there would be 
a posts directory for templates. As well I create the following files::

    base.html
    404.html
    500.html
    
These serve as the base and error templates that Django looks for.

Project Directory
^^^^^^^^^^^^^^^^^

The project directory is where the important stuff is. Here I'll place system attributes, shared files, and the settings.
The main files I will always have here are::

    dev_urls.py
    __init__.py
    urls.py
    wsgi.py
    
I place all of my settings into a settings folder in here. All of them? Yes, at work we use a tiered settings structure
rather than the typical local_settings.py trick. This ensures that you version control your system settings and only
keep passwords and keys in a local.py file. In the directory project_name/settings I have::

    __init__.py
    base.py
    dev.py
    prod.py
    local.py
    local.py.example
    
These each can be seen on my sample project: https://github.com/dansackett/django_template/tree/master/project_name/settings

Summary
^^^^^^^

This structure seems to work well for me and keeps me very organized. Once that's in place, we can run Django commands, 
build apps, and get the app running and deployed seamlessly. If you'd like to use this template, I made it easy with the template I mentioned above. There are instructions on that to help you get started.
