#!/bin/bash

# ytsearch
# original: https://coderwall.com/p/jvuzdg
# created by: Balazs Nadasdi <http://about.me/yitsushi>
# this version: https://gist.github.com/Ultrabenosaurus/8974206b2cba0f1c615a
# edited by: Dan Bennett <http://about.me/d.bennett>
# license: BSD 3-Clause <http://opensource.org/licenses/BSD-3-Clause>
#
# converted to a script for easier redistribution and development
# expanded to perform both searching and providing of URLs
#
# todo:
#     * get `-w` to launch the URL in the user's default browser rather than echo?
#     * add another flag for passing in a command name, pipes output of `-w` to the command
#     * figure out a way of not requiring re-entering search terms for `-w` usage
#
# options:
#     -h
#         print this help text in your terminal
#     -s "search term"
#         do a search for the "search term"
#         shows a list of numbers and titles, use the number with `-w` to watch the video
#     -w n "search term"
#         get URL for the nth video in the list of search results
#         currently uses `echo`, need to get this tested on other environments

# consolidate help text to a single location to minimise inconsistencies
ytsearch_help(){
    printf "%s\n" "ytsearch"
    printf "%s\n" "original: https://coderwall.com/p/jvuzdg"
    printf "%s\n" "created by: Balazs Nadasdi <http://about.me/yitsushi>"
    printf "%s\n" "this version: https://gist.github.com/Ultrabenosaurus/8974206b2cba0f1c615a"
    printf "%s\n" "edited by: Dan Bennett <http://about.me/d.bennett>"
    printf "%s\n\n" "license: BSD 3-Clause <http://opensource.org/licenses/BSD-3-Clause>"

    printf "%s\n" "converted to a script for easier redistribution and development"
    printf "%s\n\n" "expanded to perform both search and launching of videos"

    printf "%s\n" "todo:"
        printf "\t%s\n" "* get \`-w\` to launch the URL in the user's default browser rather than echo?"
        printf "\t%s\n" "* add another flag for passing in a command name, pipes output of \`-w\` to the command"
        printf "\t%s\n\n" "* figure out a way of not requiring re-entering search terms for \`-w\` usage"

    printf "%s\n" "options:"
        printf "\t%s\n" "-h"
            printf "\t\t%s\n" "print this help text in your terminal"
        printf "\t%s\n" "-s \"search term\""
            printf "\t\t%s\n" "do a search for the \"search term\""
            printf "\t\t%s\n" "shows a list of numbers and titles, use the number with \`-w\` to watch the video"
        printf "\t%s\n" "-w n \"search term\""
            printf "\t\t%s\n" "watch the nth video in the list of search results"
            printf "\t\t%s\n" "currently uses \`echo\`, need to get this tested on other environments"

    exit
}

# catch no-parameter usage
if [ -z $1 ]; then
  ytsearch_help
fi

# apparently Linux doesn't have -r flag for sed...
sed_r(){
    DIST="linux"
    case `uname -s` in
        "Darwin")
            DIST="mac"
            ;;
        "$(expr substr $(uname -s) 1 10)")
            DIST="win"
            ;;
    esac
    while getopts ":wt" opt; do
        case $opt in
            w)
                if [ $DIST == "win" ]; then
                    echo sed -r -e 's/^watch\?v=([^"]*)".*/\1/g'
                else
                    echo sed -e 's/^watch\?v=\([^"]*\)".*/\1/g'
                fi
                ;;
            t)
                if [ $DIST == "win" ]; then
                    echo sed -r -e 's/^.*title="(.*)/\1/g'
                else
                    echo sed -e 's/^.*title="\(.*\)/\1/g'
                fi
                ;;
        esac
    done
}

# main functionality
while getopts ":hw:s:" opt; do
    case $opt in
        h)
            ytsearch_help
            ;;
        w)
            oldifs="$IFS"
            IFS=$'\n'
            searchResults=($(curl -s https://www.youtube.com/results\?search_query\=$3 | \
                grep -o 'watch?v=[^"]*"[^>]*title="[^"]*' | \
                sed_r -w))
            IFS="$oldifs"
            echo "http://youtube.com/watch?v=${searchResults[$OPTARG-1]}"
            exit
            ;;
        s)
            oldifs="$IFS"
            IFS=$'\n'
            searchResults=($(curl -s https://www.youtube.com/results\?search_query\=$OPTARG))
            IFS="$oldifs"
            
            echo $searchResults
            exit
            ;;
        \?)
            printf "Invalid option: -%s\n\n" "$OPTARG"
            ytsearch_help
            ;;
        :)
            printf "Option -%s requires an argument\n\n" "$OPTARG"
            ytsearch_help
            ;;
        *)
            ytsearch_help
            ;;
    esac
done