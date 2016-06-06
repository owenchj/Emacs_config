#! /bin/sh
#Author : jie chen
#Date   : 06/06/2016
#Email  : owenchj@gmail.com


error () {
    echo "$@" 1>&2
    usage_and_exit 1
}

usage () {
    echo "Usage: $PROGRAM [--all]  [--help]  [--version] [--d] [install path]"
    echo "Example: $PROGRAM --all --d ~/.emacs.dir"

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

all=no
EXITCODE=0
PROGRAM=`basename "$0"`
VERSION=1.0
DES="$HOME/.emacs.config"

if [ $# == 0 ]
then
    error "No argument"
fi

while test "$#" -gt 0
do
    case $1 in
	--all | --al | --a | -all | -al |-a)
	all=yes
	;;
	--help | --hel | --he | --h | '--?' | -help | -hel | -he | -h | '-?')
	    usage_and_exit 0
	    ;;
	--version | --versio | --versi | --vers | --ver | --ve | --v | \
	    -version |  -versio |  -vsrsi |  -vers |  -ver |  -ve |  -v )
	    version
	    exit 0
	    ;;
	--d | -d)
	    DES="$2/.emacs.config"
	    shift
	    if [ -z "$DES" ]
	    then
		echo "Please provide valid install path!"
		usage_and_exit 0
	    fi
	    ;;
	-*)
	    error "Unrecognized option: $1 "
	    ;;
	*)
	    break
	    ;;
    esac
    shift
done

command -v git >/dev/null 2>&1 ||
{
    echo -e "\e[0;31mCheck no git, install git\e[0m"
    sudo apt-get install git-all
}

if [ "$all" == 'yes' ]
then
    if [ ! -d "$DES" ]
    then
	echo "Destination does not exist, create (yes/no)?"
	read input
	if [ "$input" == "y" -o "$input" == "yes" ]
	then
	    echo "create $DES"
	    mkdir -p "$DES"
	else
	    exit 0;
	fi
    fi

    config_dir="$DES"

    echo -e "\e[0;33m[Download neotree]\e[0m"
    git clone git@github.com:jaypei/emacs-neotree.git

    echo -e "\e[0;33mDownload auto-complete\e[0m"
    tar -xjf auto-complete-1.3.1.tar.bz2


    echo -e "\e[0;33mInstall neotree\e[0m"
    mv "`pwd`/emacs-neotree" "$config_dir"

    echo ";;neotree" >> .emacs.el
    echo "(add-to-list 'load-path \""$config_dir/emacs-neotree"\")" >> .emacs.el
    echo "(require 'neotree)" >> .emacs.el
    echo "(global-set-key [f8] 'neotree-toggle)" >> .emacs.el

    echo -e "\e[0;33mInstall auto-complete\e[0m"
    ac_dir="`pwd`/auto-complete-1.3.1"
    install_dir="$config_dir/.auto"
    mkdir -p $install_dir
    cd $ac_dir
    make install DIR="$install_dir"

    cd -
    echo ";;auto-complete" >> .emacs.el
    echo "(add-to-list 'load-path \""$install_dir"\")" >> .emacs.el
    echo "(require 'auto-complete-config)" >> .emacs.el
    echo "(add-to-list 'ac-dictionary-directories \""$install_dir/ac-dict"\")" >> .emacs.el
    echo "(ac-config-default)" >> .emacs.el

    file="`pwd`/.emacs.el"
    if [ -f "$file" ]
    then
	echo "copy .emacs.el"
	cp -rf $file "$HOME"
    fi

fi

test $EXITCODE -gt 125 && EXITCODE=125
exit $EXITCODE
