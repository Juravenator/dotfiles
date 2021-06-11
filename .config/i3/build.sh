#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
IFS=$' \n\t\v'
cd `dirname "${BASH_SOURCE[0]:-$0}"`

echo "###########################################################"
echo "# Automatically generated on $(date)"
echo "# Do not edit. Rather, re-generate using command"
echo "# bash build.sh $@ > config"
echo "###########################################################"
echo ""

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

alreadydone=()
include () {
  local trait="$1"
  local oldwd=$(pwd)
  if containsElement "$trait" "${alreadydone[@]}"; then
    >&2 echo -e "\e[33mWARN: ignoring double include of '$trait'\e[0m"
  elif [[ ! -f "$trait" ]]; then
    >&2 echo -e "\e[31mERROR: trying to include non existing '$trait'\e[0m"
    exit 1
  else
    >&2 echo "inlining '$trait'"
    echo "## include $trait"
    alreadydone+=("$trait")

    cd `dirname "$trait"`
    while IFS='' read line || [ -n "$line" ]; do # if last line doesn't contain \n, -n saves it
      if [[ "$line" =~ ^include[[:space:]].* ]]; then
        include "${line:8}"
      elif [[ "$line" =~ ^[[:space:]]*\#.* || "$line" == "" ]]; then
        :
      else
        echo "$line"
      fi
    done < "$(basename $trait)"
    echo "## /include $trait"
    cd "$oldwd"
  fi
  return 0
}

include "traits/global"
for trait in "$@"; do
  include "$trait"
done

>&2 echo "done!"

# array=("something to search for" "a string" "test2000")
# $ containsElement "a string" "${array[@]}"

# for var in "$@"; do
#     # echo "$var"
# done

# while read p; do
#   echo "$p"
# done <peptides.txt

# if test -f "$FILE"; then
#     echo "$FILE exists."
# fi