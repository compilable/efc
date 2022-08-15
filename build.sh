#!/bin/bash


# build script to release the latest version.


# 1 remove existing bin folder
rm -rf bin

# 2 create a bin foldeer and copy the scripts to the new build folder
mkdir -p bin
cp efc bin
cp efc_lib bin

# 3 rename the efc file to new version : efc_VERSION

echo "new version number (vXX.XX.XX): "
read version


# 4 create the minified version

cat efc_lib >> "bin/efc_min"
cat efc >> "bin/efc_min"

# 5 marking the script with the version & copy the license and Readme

mv bin/efc "bin/efc_$version"
mv bin/efc_min "bin/efc_$version.min"

# Make a copy of the min file to be execcuted by calling the efc command
cp "bin/efc_$version.min" "bin/efc"

cp License "bin/"
cp README.md "bin/"

# 6 compress the bin folder into release folder

mkdir -p release

echo "creating the build.."
tar -czvf "release/efc_$version.tar.gz" bin/

tar -czvf "release/efc_min_$version.tar.gz" bin/efc

echo "build completed for the version : $version"