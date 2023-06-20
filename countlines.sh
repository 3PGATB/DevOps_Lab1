#!/usr/bin/env bash

#
# Author: Art Bugorski
# E-Mail: arthur.bugorski@3pillarglobal.com
# Date: 2023-06-19
#


#
# Variables
#

feature='' ;
have_determined_feature=''; #false
desired_value='root';
error_occurred=''; #false


#
# Parse command line options
#

while getopts 'm:o:' arg; do
    case $arg in
	'm')
	    if [[ $have_determined_feature ]]; then
		error_occurred=true ;
	    else		
		have_determined_feature=true ;
		feature='month' ;
		desired_value="$OPTARG" ;
	    fi	    
	    ;;
	'o')
	    if [[ $have_determined_feature ]]; then
		error_occurred= true ;
	    else
		have_determined_feature=true ;
		feature='user' ;
		desired_value="$OPTARG" ;
	    fi
	    ;;
	*)
	    # unknown flag case
	    error_occurred= true ;
	    ;;
    esac
done


#
# Check for errors, if so, print usages and exit.
#

if [[ ! $have_determined_feature ]]; then
    error_occurred=true ;
fi

if [[ $error_occurred ]]; then
    >&2 echo "Usage: $0 (-o owner|-m month)"
    exit -1 ;
else
    # DEBUG
    # echo "looking for $feature $desired_value" ;
    true ;
fi


#
# Worker functions
#

function get_user(){
    stat --format='%U' "$1" ;
}

function get_month(){
    ls -l "$1" | cut --delimiter ' ' --fields 6 ;
}

function get_linecount(){
    wc --lines "$1" | cut --delimiter ' ' --fields 1 ;
}


#
# Main loop, iterate through files
#

echo "Looking for files where the $feature is: $desired_value" ;
value='' ;
for file in $(  ls  $( pwd )  ); do
    if ! [[ -d "$file" ]]; then
	case $feature in
	    'user')
		value=$( get_user "$file" );
		;;
	    'month')
		value=$( get_month "$file" ) ;
		;;
	esac

	if [[ "$desired_value" = "$value" ]]; then
	    line_count=$( get_linecount "$file" ) ;
	    echo "File: $file, Lines: $line_count $file" ;
	fi
    fi
done
