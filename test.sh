#!/bin/bash

shopt -s globstar

gpg --quiet --yes --batch --passphrase "$2" "$1"  2>> "$1_out"


if grep -q failed "$1_out"; then
  echo "faild"
fi

rm -f -- "$1_out"