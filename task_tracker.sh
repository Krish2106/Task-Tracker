#!/bin/bash
KEYWORD="TODO"
HEAD=$(git rev-parse --show-toplevel)
TASKS_FILE_NAME="pending_tasks.md"
EXCLUDE=''


# h - help
# f - output file
# e - exclude certain files
while getopts "hf:s:e:" option; do
    case $option in
        'h' )
            echo -e "\n"
            echo "$(basename "$0") - generate a pending tasks file for the codebase"
            echo "-----------------------------------------------------------------"
            echo -e "\n"
            echo "Required commenting format is to use the KEYWORD (defaults to TODO) followed by a semicolon "
            echo "eg: TODO: Move values to config"
            echo -e "\n"
            echo    "  -h - echo help options"
            echo -e "\n"
            echo    "  -f - takes filename to write to"
            echo -e "\n"
            echo    "  -e - exclude pattern"
            echo -e "\n"
            echo    "  -s - custom search keyword which defaults to TODO"
            echo -e "\n"
            exit
        ;;
        's' )
            KEYWORD=$OPTARG
        ;;
        'f' )
            TASKS_FILE_NAME=$OPTARG
        ;;
        'e' )
            EXCLUDE="$EXCLUDE$OPTARG|"
        ;;
    esac
done


EXCLUDE=$EXCLUDE$TASKS_FILE_NAME
#echo "$EXCLUDE"

TASKS_FILE_NAME="$HEAD/$TASKS_FILE_NAME"
exec 1>"$TASKS_FILE_NAME"


echo -e "\n ## Pending Tasks"

# git grep used:
#   -E - POSIX extended regexp
#   -I - Don’t match the pattern in binary files.
#   -i - Ignore case differences between the patterns and the files.
#   -n - include line numbers
#   -w - Match the pattern only at word boundary

IFS=$'\n' todos=($(git grep -EIinw "$KEYWORD" "$HEAD" | egrep -v "($EXCLUDE)"))

#todos=($(git grep -EIinw "$KEYWORD" "$HEAD" | egrep -v "($EXCLUDE)"))

origin_file=''
for item in "${todos[@]}"; do

    file=$(echo "$item" | cut -f1 -d':')

    line=$(echo "$item" | cut -f2 -d':')

    comment=$(echo "$item" | cut -f4- -d':')
 
    if [[ $file != "$origin_file" ]]; then
        if [ $origin_file ]; then
            echo
        fi
        origin_file=$file
        echo -e "--------------------"
        echo "**Source_file**: $origin_file"
        echo
    fi
    echo "(line $line): $comment"
    echo
done
