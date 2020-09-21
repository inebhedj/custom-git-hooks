#!/bin/sh

# CUSTOM-GIT-HOOK-SKELETON
# This script should be saved in a git repo as a hook file, e.g. .git/hooks/pre-receive.
# It looks for scripts in the .git/hooks/pre-receive.d directory and executes them in order 
# (except *.sample and *.backup files), passing along stdin. 
# If any script exits with a non-zero status, this script exits.

script_dir=$(dirname $0)
hook_name=$(basename $0)

hook_dir="$script_dir/$hook_name.d"
sample_backup_regex="^.*\.(?:sample|backup)$"

if [ -d "$hook_dir" ]; then
  stdin=$(cat /dev/stdin)
  
  for hook in $(ls -p $hook_dir/ | grep -v / | sort -V); do
    hook_file="$(basename $hook)"
    
    (  echo "$hook_file" | grep -Eq  "$sample_backup_regex" )  && regex_check="1" || regex_check="0"
    
    if [ $regex_check = "0" ]; then

      hook_cmd="$hook_dir/$hook_file"
      echo "Running $hook_cmd hook"
      echo "$stdin" | $hook_cmd "$@"

      exit_code=$?

      if [ $exit_code != 0 ]; then
        exit $exit_code
      fi
    fi
  done
fi

exit 0