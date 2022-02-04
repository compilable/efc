#!/bin/bash



read_version(){
    while IFS= read -r line; do 
        if [[ "$line" == ???EFC* ]]
        then
            echo -e "$line"
            break
        fi
    done < CHANGELOG.md
}



read_version