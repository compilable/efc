#!/bin/bash


# build script to release the latest version.


# 1 remove existing bin folder
rm -rf bin

# 2 create a bin foldeer and copy the scripts to the new build folder
mkdir -p bin
cp efc.sh bin
cp efc_lib.sh bin

# 3 rename the efc.sh file to new version : efc_VERSION.sh

echo "new version number (vXX.XX.XX): "
read version


# 4 create the minified version

cat efc_lib.sh >> "bin/efc_min.sh"
cat efc.sh >> "bin/efc_min.sh"

# 5 marking the script with the version 

mv bin/efc.sh "bin/efc_$version.sh"
mv bin/efc_min.sh "bin/efc_$version.min.sh"

# 6 compress the bin folder into release folder

mkdir -p release

echo "creating the build.."
tar -czvf "release/efc_$version.tar.gz" bin/

tar -czvf "release/efc_min_$version.tar.gz" bin/efc_$version.min.sh

echo "build completed for the version : $version"