#!/bin/sh


hooks_dir=".git/hooks"
gitignore_file=".gitignore"

script_path="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
custom_git_hooks_dir=$(basename "$script_path")
working_git_root=$(dirname "$script_path")

install_hook_folder="$script_path/data"
install_hook_list="hooklist.txt"
install_hook_skeleton="multiple-git-hooks.sh"
install_hook_skeleton_id="CUSTOM-GIT-HOOK-SKELETON"
install_remove_list="removelist.txt"

install_date=$(date '+%Y%m%d%H%M%S')

echo "custom-git-hooks-install ($install_hook_skeleton_id) - environment on $install_date:

* hooks_dir: $hooks_dir
* gitignore_file: $gitignore_file

* script_path: $script_path
* custom_git_hooks_dir: $custom_git_hooks_dir
* working_git_root: $working_git_root

* install_hook_folder: $install_hook_folder
* install_hook_list: $install_hook_list
* install_hook_skeleton: $install_hook_skeleton
* install_remove_list: $install_remove_list

"

if [ -d "$working_git_root/$hooks_dir/" ] && [ -d "$install_hook_folder" ] && [ -f "$install_hook_folder/$install_hook_skeleton" ] && [ -f "$install_hook_folder/$install_hook_list" ]; then 

    if [ -f "$install_hook_folder/$install_remove_list" ]; then
        while read -r remove_file; do
            echo "Remove outdated / deprecated file $hooks_dir/$remove_file"
            rm "$working_git_root/$hooks_dir/$remove_file"
            if grep -Fxq "!$hooks_dir/$remove_file" "$working_git_root/$gitignore_file"
            then
                echo "* Set comment into $gitignore_file for delete"
                echo "* Please, don't forget check, update, cleanup and commit $gitignore_file after commited the changes of this installation!"
                sed -i "s/!$hooks_dir/$remove_file/# $install_hook_skeleton_id on $install_date: REMOVE THIS AND NEXT LINES!\n$!$hooks_dir/$remove_file/" "$working_git_root/$gitignore_file"
            fi
        done <"$install_hook_folder/$install_remove_list"
    fi

    if ! grep -Fxq "$custom_git_hooks_dir" "$working_git_root/$gitignore_file"
    then
        echo "Insert $custom_git_hooks_dir/ into $gitignore_file to prevent your repository"
        echo "# $install_hook_skeleton_id on $install_date:" >> "$working_git_root/$gitignore_file"
        echo "$custom_git_hooks_dir/" >> "$working_git_root/$gitignore_file"
        echo "$custom_git_hooks_dir/*" >> "$working_git_root/$gitignore_file"
        echo "/$custom_git_hooks_dir/" >> "$working_git_root/$gitignore_file"
        echo "/$custom_git_hooks_dir/*" >> "$working_git_root/$gitignore_file"
    fi

    while read -r hook_file; do

        new_subdir="$hook_file.d"
        if [ ! -d "$working_git_root/$hooks_dir/$new_subdir/" ]; then
            echo "Create $hooks_dir/$new_subdir"
            mkdir "$working_git_root/$hooks_dir/$new_subdir"
        fi

        if [ -d "$working_git_root/$hooks_dir/$new_subdir/" ]; then

            if [ -f "$working_git_root/$hooks_dir/$hook_file.sample" ]; then
                if  [ -f "$working_git_root/$hooks_dir/$new_subdir/$hook_file.sample" ]; then
                    echo "** Backup $hooks_dir/$new_subdir/$hook_file.sample to $hooks_dir/$new_subdir/$hook_file.sample.$install_date.backup"
                    mv "$working_git_root/$hooks_dir/$new_subdir/$hook_file.sample" "$working_git_root/$hooks_dir/$new_subdir/$hook_file.sample.$install_date.backup"
                fi
                echo "* Move $hooks_dir/$hook_file.sample to $hooks_dir/$new_subdir/$hook_file.sample"
                mv "$working_git_root/$hooks_dir/$hook_file.sample" "$working_git_root/$hooks_dir/$new_subdir/$hook_file.sample"
            fi

            if [ -f "$working_git_root/$hooks_dir/$hook_file" ] && ! grep -q "$install_hook_skeleton_id" "$working_git_root/$hooks_dir/$hook_file"
            then
                if [ -f "$working_git_root/$hooks_dir/$new_subdir/99-$hook_file" ]; then
                    echo "** Backup $hooks_dir/$new_subdir/99-$hook_file to $hooks_dir/$new_subdir/99-$hook_file.$install_date.backup"
                    mv "$working_git_root/$hooks_dir/$new_subdir/99-$hook_file" "$working_git_root/$hooks_dir/$new_subdir/99-$hook_file.$install_date.backup"
                fi
                echo "* Move $hooks_dir/$hook_file to $hooks_dir/$new_subdir/99-$hook_file"
                mv "$working_git_root/$hooks_dir/$hook_file" "$working_git_root/$hooks_dir/$new_subdir/99-$hook_file"
            fi


            echo "* Copy / update $install_hook_folder/$install_hook_skeleton to $hooks_dir/$hook_file"
            cp "$install_hook_folder/$install_hook_skeleton" "$working_git_root/$hooks_dir/$hook_file"
            chmod +x "$working_git_root/$hooks_dir/$hook_file"

            if [ -d "$install_hook_folder/$hook_file.d/" ]; then

                echo "Found $install_hook_folder/$hook_file.d/"
                echo "Processing..."

                
                for hook in $(find "$install_hook_folder/$hook_file.d/" -type f -name "*" -print0); do

                    work_hook="$(basename "$hook")"
                    echo "* Copy / update $install_hook_folder/$hook_file/$work_hook to $hooks_dir/$new_subdir/$work_hook"
                    cp "$install_hook_folder/$hook_file.d/$work_hook" "$working_git_root/$hooks_dir/$new_subdir/$work_hook"
                    chmod +x "$working_git_root/$hooks_dir/$new_subdir/$work_hook"

#                    if ! grep -Fxq "!$hooks_dir/$hook_file" "$working_git_root/$gitignore_file"
#                    then
#                        echo "** Insert exception for $hooks_dir/$hook_file into $gitignore_file"
#                        echo "# $install_hook_skeleton_id on $install_date:" >> "$working_git_root/$gitignore_file"
#                        echo "!$hooks_dir/$hook_file" >> "$working_git_root/$gitignore_file"
#                    fi 

#                    if ! grep -Fxq "!$hooks_dir/$new_subdir/$work_hook" "$working_git_root/$gitignore_file"
#                    then
#                        echo "** Insert exception for $hooks_dir/$new_subdir/$work_hook into $gitignore_file"
#                        echo "# $install_hook_skeleton_id on $install_date:" >> "$working_git_root/$gitignore_file"
#                        echo "!$hooks_dir/$new_subdir/$work_hook" >> "$working_git_root/$gitignore_file"
#                    fi

                done

                echo "Done."
            fi

        else 
            echo "No available $hooks_dir/$new_subdir"
            exit 1;
        fi    

    done <"$install_hook_folder/$install_hook_list"


    echo "All done."
    exit 0;

else
    echo "No available $hooks_dir ($working_git_root/$hooks_dir) or $install_hook_folder or $install_hook_folder/$install_hook_skeleton or $install_hook_folder/$install_hook_list"
    exit 1;
fi
