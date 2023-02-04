## Usecase : Output location update for single file.

`Set the FQ path for the source and destination.`

# Test 1 : encrypt with given file name:
./efc -s "/home/userx/workspace/efc_masnon/efc/test/test_data/ASIC-pre-loader.gif" -o "/home/userx/workspace/efc_masnon/efc/test/ouput/encrypted.gpg" -t e -p "test/local.passphrase.txt" -d yes

# Test 2 : decrypt with given file name:
./efc -s "/home/userx/workspace/efc_masnon/efc/test/ouput/encrypted.gpg" -o "/home/userx/workspace/efc_masnon/efc/test/test_data/ASIC-pre-loader.gif" -t d -p "test/local.passphrase.txt" -d yes

# Test 3 : encrypt without a given file name:
./efc -s "/home/userx/workspace/efc_masnon/efc/test/test_data/ASIC-pre-loader.gif" -t e -p "test/local.passphrase.txt" -d yes

# Test 4 : decrypt without a given file name:
./efc -s "/home/userx/workspace/efc_masnon/efc/test/test_data/ASIC-pre-loader.gif.gpg" -t d -p "test/local.passphrase.txt" -d yes

## Usecase : Output location update for folder.
# Test 1 : encrypt with given output folder location:
./efc -s "/home/userx/workspace/efc_masnon/efc/test/test_data" -o "/home/userx/workspace/efc_masnon/efc/test/test_data/output_data/" -t e -p "test/local.passphrase.txt" -d yes

# Test 2: decrypt with given output folder location:
./efc -s "/home/userx/workspace/efc_masnon/efc/test/test_data/output_data" -o "/home/userx/workspace/efc_masnon/efc/test/test_data" -t d -p "test/local.passphrase.txt" -d yes

# Test 3 : encrypt without giving an output folder location:
./efc -s "/home/userx/workspace/efc_masnon/efc/test/test_data" -t e -p "test/local.passphrase.txt" -d yes

# Test 4 : decrypt without giving an output folder location:
./efc -s "/home/userx/workspace/efc_masnon/efc/test/test_data" -t d -p "test/local.passphrase.txt" -d yes
