#!/bin/bash

source_path=$(pwd)
source "$source_path/../obscure_lib.sh"


pword_1="random text-2#"
test_file="test_data/"
test_file_output="test_data/ENC_ASIC-pre-loader"

generate_index_file "$test_file" "$pword_1"