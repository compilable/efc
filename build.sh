#!/bin/bash

# build script to release the latest version.

extract_version_from_file() {

    file="CHANGELOG.md"

    if [[ -f "$file" ]]; then

        while IFS= read -r line; do
            if [[ "$line" == ???EFC* ]]; then
                echo -e "\n$line \n## Source : https://github.com/compilable/efc/ \n## License : The MIT License (MIT)\n## Copyright 2002-2022 compilable@tuta.io"
                break
            fi
        done <$file

    else
        echo -e "\n## EFC - version : unknown. \n## Source : https://github.com/compilable/efc/\n## License : The MIT License (MIT)\n## Copyright 2002-2022 compilable@tuta.ioo"
        exit
    fi

}

# 1 remove existing bin folder
rm -rf bin

# 2 create a bin folder
mkdir -p bin

# 3 collect new version from user : efc_VERSION
echo "new version number (vXX.XX.XX): "
read version

# 4 minify the efc and lib file content by combining all the sh file content into a single file with the name efc
cat efc_lib >>"bin/efc_min"
cat efc >>"bin/efc_min"

# 5 marking the script with the version & copy the license and Readme
mv bin/efc_min "bin/efc"

# 6 include README.md , include License
cp License "bin/"
cp README.md "bin/"

# 7 Add version info to the end of the efc scrip file.
version_info=$(extract_version_from_file)
echo -e $version_info
echo "$version_info" >>"bin/efc"

# 8 compress the bin folder into release folder
mkdir -p release
echo "creating the build.."
tar -czvf "release/efc_$version.tar.gz" bin/

echo -e "\nbuild completed for the version : $version"
