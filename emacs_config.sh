#! /bin/sh

#IFS='
# Test:
# pathfind PATH $(awk 'BEGIN { while(n<150) printf("x.%d ", ++n)  }' )A
# pathfind -a PATH c88 cad icc c99 gcc c++ cc g++ >foo.out 2>foo.err


OLDPATH="$PATH"
PATH=/bin:/usr/bin
export PATH

error () {
    echo "$@" 1>&2
    usage_and_exit 1
}

usage () {
    echo "Usage: $PROGRAM [--all]  [--?]  [--help]  [--version] [-d] [install path]"
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
	-d )
	    DES="$2"
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

if [ -z "$DES" ]
then
    DES="~/"
fi

command -v git >/dev/null 2>&1 ||
{
    echo "Check no git, install git ++++"
    sudo apt-get install git-all
}

if [ "$all" == 'yes' ]
then
    config_dir=$DES/.emacs.config
    #echo $config_dir
    mkdir $config_dir
    cd $config_dir

    echo "[--Download neotree--]"
    git clone git@github.com:jaypei/emacs-neotree.git

    echo "[--Download neotree--]"
    git clone git@github.com:jaypei/emacs-neotree.git
    echo "[--Download auto-complete--]"
    git clone git@github.com:auto-complete/auto-complete.git

    #
    echo "[--Install neotree--]"
    file="`pwd`/.emacs.el"
    echo $file
    if [ -f "$file" ]
	then
	cp -rf $file ~/
    fi

    #
    echo "[--Install auto-complete--]"
    ac_dir="`pwd`/auto-complete"
    install_dir="`pwd`/.auto" && mkdir $install_dir
    echo $install_dir
    #cd $ac_dir && make install DIR="$install_dir"
fi

test $EXITCODE -gt 125 && EXITCODE=125
exit $EXITCODE
