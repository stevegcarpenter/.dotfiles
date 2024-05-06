#!/bin/sh

# List of file extensions to check
extensions="ts tsx js jsx"

# Empty variable to store files containing console.log
files_with_logs=""

# Loop through all staged files
for file in $(git diff --cached --name-only --diff-filter=AM)
do
    # Check if the file has the proper extension
    for ext in $extensions
    do
        if [[ $file == *.$ext ]]; then
            # Grep for console.log in the file
            git show ":$file" | grep -E 'console.log' > /dev/null
            if [ $? -eq 0 ]; then
                files_with_logs+="${file}\n"
            fi
            break
        fi
    done
done

if [ -n "$files_with_logs" ]; then
    echo "\033[0;31mERROR: Please remove console.log before committing the following files:\033[0m"
    echo "\033[0;31m-------------------------------------------------------------------------------\033[0m\n"
    echo "$files_with_logs"
    echo "\033[0;31m-------------------------------------------------------------------------------\033[0m"
    exit 1
else
    exit 0
fi
