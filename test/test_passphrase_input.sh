#!/bin/bash

source_path=$(pwd)
source "$source_path/../efc_lib"

function test_read_from_file() {
    password=''
    extract_password local.passphrase.txt
    echo "$password"
}

function test_read_from_url() {
    password=''
    extract_password https://raw.githubusercontent.com/compilable/efc/4-read-the-passphrase-from-a-url/test/test_data/remote.passphrase.txt
    echo "$password"
}

function test_read_from_incorrect_file() {
    password=''
    extract_password test_data/no_file.passphrase.txt
    echo "$password"
}

function test_read_from_incorrect_url() {
    password=''
    extract_password https://broken.githubusercontent.com/compilable/efc/4-read-the-passphrase-from-a-url/test/remote.passphrase.txt
    echo "$password"
}

echo "test 1: test_read_from_file"
test_read_from_file

echo "test 2: test_read_from_url"
test_read_from_url

echo "test 3: test_read_from_incorrect_file"
test_read_from_incorrect_file

echo "test 4: test_read_from_incorrect_url"
test_read_from_incorrect_url
