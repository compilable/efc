#!/bin/bash

source_path=$(pwd)
source "$source_path/../efc_lib.sh"


password="random text-2#"
test_file="test_data/ASIC-pre-loader.gif"
test_file_output="test_data/ENC_ASIC-pre-loader"

# test 1 : encryption
encrypt "$test_file" "$password" "yes" "$test_file_output"
    # $1 = fq file name
    # $2 = password
    # $3 = delete flag (yes/no)
    # $4 = output file name [optional]    
    

# test 2 : decryption
decrypt "$test_file_output" "$password" "yes" "$test_file"
    # $1 = fq file name
    # $2 = password
    # $3 = delete flag (yes/no)
    # $4 = output file name [optional]