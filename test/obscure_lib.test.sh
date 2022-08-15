#!/bin/bash

source_path=$(pwd)
source "$source_path/../obscure_lib.sh"

# TODO:
#    update the obscure_lib.sh path to :
#    source "../efc_lib.sh"
#
pword_1="random text-2#"
pword_2="second_pass-2"
source_location="test_data/"

# encrypt
construct_index_file "$source_location" "$pword_1"
#reconstruct_index_file "test_data/.20220412222517.asc" "$pword_1"
#process_indexed_content "e" "$pword_2"

# decrypt
#reconstruct_index_file "test_data/.20220412222517.asc" "$pword_1"
#process_indexed_content "d" "$pword_2"

