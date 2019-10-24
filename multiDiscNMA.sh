#!/usr/bin/env bash

usage_error() {
  echo "Usage: $0 [-d] analyses_suite_text_file.txt" >&2
  exit 1
}

file_not_found_error() {
  echo "$1 not found" >&2
  exit 1
}

if [ ${#} -eq 0 ] || [ ${#} -gt 2 ]; then
  usage_error
elif [ ${#} -eq 2 ]; then
  while getopts "d" opt; do
    case $opt in
      d ) suite_file=$2 ; debug="TRUE" ;;

     \? ) usage_error  ;;
   esac
  done
else
  suite_file=$1
  debug="FALSE"
fi

if [ ! -f $suite_file ]; then
  file_not_found_error $suite_file
fi

echo "Running the analyses in "$suite_file"..."

IFS=$'\n'
set -f
for line in $(cat $suite_file); do
  echo "##########################################"
  echo "Running "$line
  echo "##########################################"
  RScript code_nma/project.R $line" "$debug
done

echo "Analyses in "$suite_file" completed!"
