#!/bin/sh


hooks_dir="./.git/hooks"
install_hook_folder="./custom-git-hooks"
install_hook_skeleton="multiple-git-hooks.sh"



if [ -d "$hooks_dir/" ] && [ -d "$install_hook_folder" ] && [ -f "$install_hook_folder/$install_hook_skeleton" ]; then 
    for file in $(find ./.git/hooks -type f -name "*.sample"); do
        work_file="$(basename $file)"
        new_subdir=$(echo "$work_file" | sed 's/\.sample$/.d/g')
        hook_file=$(echo "$work_file" | sed 's/\.sample$//g')
        if [ ! -d "$hooks_dir/$new_subdir/" ]; then
            echo "Create $hooks_dir/$new_subdir"
            mkdir "$hooks_dir/$new_subdir"
        fi
        if [ -d "$hooks_dir/$new_subdir/" ]; then
            echo "Move $hooks_dir/$work_file to $hooks_dir/$new_subdir/$work_file"
            mv "$hooks_dir/$work_file" "$hooks_dir/$new_subdir/$work_file"
            if [ -f "$hooks_dir/$hook_file" ]; then
                echo "Move $hooks_dir/$hook_file to $hooks_dir/$new_subdir/99-$hook_file"
                mv "$hooks_dir/$hook_file" "$hooks_dir/$new_subdir/99-$hook_file"
            fi
            echo "Copy install_hook_folder/$install_hook_skeleton to ${hooks_dir}/${hook_file}"
            cp "$install_hook_folder/$install_hook_skeleton" "${hooks_dir}/${hook_file}"
            if [ -d "$install_hook_folder/$hook_file/" ]; then
                echo "Found $install_hook_folder/$hook_file/"
                echo "Processing..."
                for inda_hook in $(find "$install_hook_folder/$hook_file/" -type f -name "*"); do
                    work_inda_hook="$(basename $inda_hook)"
                    echo "Copy $install_hook_folder/$hook_file/$work_inda_hook to $hooks_dir/$new_subdir/$work_inda_hook"
                    cp "$install_hook_folder/$hook_file/$work_inda_hook" "$hooks_dir/$new_subdir/$work_inda_hook"
                done
                echo "Done."
            fi
        else 
            echo "No available $hooks_dir/$new_subdir"
            exit 1;
        fi
    done
    echo "All done."
    exit 0;
else
    echo "No available $hooks_dir or $install_hook_folder or $install_hook_folder/$install_hook_skeleton"
    exit 1;
fi