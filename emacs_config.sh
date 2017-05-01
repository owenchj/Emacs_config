#! /bin/bash
#Author : jie chen
#Date   : 06/06/2016
#         12/04/2017
#Email  : owenchj@gmail.com


error () {
    echo "$@" 1>&2
    usage_and_exit 1
}

usage () {
    echo "Usage: $PROGRAM [OPTION]... [INSTALL_PATH]..."
    echo "  or:  $PROGRAM [OPTION]..."
    echo "Install emacs configuration to INSALL_PATH or default directory with several plugins."
    echo ""
    echo "-A  --all          install all plugins"
    echo "    --auto         add auto-complete plugin"
    echo "    --neotree      add neotree plugin"
    echo "    --ws           add while-space control plugin"
    echo "-G  --gitconfig    config git environment for emacs"
    echo "-d  --directory    install destination"
    echo "    --help         display this help and exit"
    echo "    --version      outplay version information and exit"

    echo "Example: $PROGRAM -A -d ~/.emacs.dir"

}

usage_and_exit () {
    usage
    exit "$1"
}

version () {
    echo "$PROGRAM version is $VERSION"
}

warning () {
    echo "$@" 1>&2
    EXITCODE=`expr $EXITCODE + 1`

}

install_auto () {
    # Decompression
    ac_dir="$CONFIG_DIR/auto-complete-1.3.1"
    echo -e "\e[0;33m[Download auto-complete]\e[0m"
    tar -xjf auto-complete-1.3.1.tar.bz2 -C $CONFIG_DIR
    # Install
    echo -e "\e[0;33mInstall auto-complete\e[0m"
    install_dir="$CONFIG_DIR/.auto"
    mkdir -p $install_dir
    cd $ac_dir
    make install DIR="$install_dir"
    # Return back
    cd -
    echo ";;auto-complete" >> $EMACS_EL_COPY
    echo "(add-to-list 'load-path \""$install_dir"\")" >> $EMACS_EL_COPY
    echo "(require 'auto-complete-config)" >> $EMACS_EL_COPY
    echo "(add-to-list 'ac-dictionary-directories \""$install_dir/ac-dict"\")" >> $EMACS_EL_COPY
    echo "(ac-config-default)" >> $EMACS_EL_COPY
}

install_neotree () {
    # Git clone
    echo -e "\e[0;33m[Download neotree]\e[0m"
    git clone git@github.com:jaypei/emacs-neotree.git "$CONFIG_DIR/emacs-neotree"
    echo -e "\e[0;33mInstall neotree\e[0m"
    # Install
    echo ";;neotree" >> $EMACS_EL_COPY
    echo "(add-to-list 'load-path \""$CONFIG_DIR/emacs-neotree"\")" >> $EMACS_EL_COPY
    echo "(require 'neotree)" >> $EMACS_EL_COPY
    echo "(global-set-key [f8] 'neotree-toggle)" >> $EMACS_EL_COPY
}

install_ws () {
    FILE_EL="`pwd`/ws-trim.el"
    cp -rf $FILE_EL "$CONFIG_DIR"

    FILE_EL="`pwd`/clean-aindent-mode.el"
    cp -rf $FILE_EL "$CONFIG_DIR"
}

git_config () {
    cp -f diff.py $CONFIG_DIR/.diff
    cp -f gitmessage $CONFIG_DIR/.gitmessage
    echo "" >> ~/.gitconfig
    echo "[commit]" >> ~/.gitconfig
    echo "        template = $CONFIG_DIR/.gitmessage" >> ~/.gitconfig
    echo "[diff]" >> ~/.gitconfig
    echo "        external = $CONFIG_DIR/.diff" >> ~/.gitconfig
}

ALL=no
AUTO=no
NEOTREE=no
WS=no
GIT_CONFIG=no

EXITCODE=0
PROGRAM=`basename "$0"`
VERSION=1.1
DIR="$HOME/.emacs.config"
EMACS_EL=.emacs.el
EMACS_EL_COPY=.emacs.el.copy
rm -f "$EMACS_EL_COPY"

if [ $# == 0 ]
then
    error "No argument"
fi

while test "$#" -gt 0
do
    case $1 in
        -A | --all)
            ALL=yes
            ;;
        --auto)
            AUTO=yes
            ;;
        --neotree)
            NEOTREE=yes
            ;;
        --ws)
            WS=yes
            ;;
        -G | --gitconfig)
            GIT_CONFIG=yes
            ;;
        -d | --directory)
            DIR="$2/.emacs.config"
            if [ -z "$2" ]
            then
                echo "Please provide valid install path!"
                usage_and_exit -1
            fi
            # next parameter
            shift
            ;;
        --help)
            usage_and_exit 0
            ;;
        --version)
            version
            exit 0
            ;;
        -*)
            INVALID_COMMAND=`echo "$1"| sed 's/-//'`
            echo "$PROGRAM: invalid option -- $INVALID_COMMAND"
            echo "Try '$PROGRAM --help' for more information."
            exit -1
            ;;
        *)
            break
            ;;
    esac
    shift
done

# Check git tools
command -v git >/dev/null 2>&1 ||
    {
        echo -e "\e[0;31mCheck no git, install git\e[0m"
        sudo apt-get install git-all
    }

# Create directory
if [ ! -d "$DIR" ]
then
    echo "Install destination does not exist, create (yes/no)?"
    read input
    if [ "$input" == "y" -o "$input" == "yes" ]
    then
        echo "create $DIR"
        mkdir -p "$DIR"
    else
        exit 0
    fi
fi

CONFIG_DIR="$DIR"

cp $EMACS_EL $EMACS_EL_COPY
# Start install
if [ "$ALL" == 'yes' ]
then
    install_auto
    install_neotree
    install_ws
fi

if [ "$AUTO" == "yes" ]
then
    install_auto
fi

if [ "$NEOTREE" == "yes" ]
then
    install_neotree
fi

if [ "$WS" == "yes" ]
then
    install_ws
fi

if [ "$GIT_CONFIG" == "yes" ]
then
    git_config
fi

# Copy .emacs.el
if [ -f "$EMACS_EL_COPY" ]
then
    echo "copy .emacs.el"
    mv -f $EMACS_EL_COPY "$HOME/$EMACS_EL"
fi

test $EXITCODE -gt 125 && EXITCODE=125
exit $EXITCODE
