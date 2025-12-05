#!/usr/bin/env bash

# Script to download the FMA dataset
cd ../data

fma_metadata() {
    curl -O https://os.unil.cloud.switch.ch/fma/fma_metadata.zip
    echo "f0df49ffe5f2a6008d7dc83c6915b31835dfe733  fma_metadata.zip" | sha1sum -c -
    echo "Extracting fma_metadata.zip..."
    unzip -o fma_metadata.zip -d fma_metadata
}
fma_small() {
    curl -O https://os.unil.cloud.switch.ch/fma/fma_small.zip
    echo "ade154f733639d52e35e32f5593efe5be76c6d70  fma_small.zip" | sha1sum -c -
    echo "Extracting fma_small.zip..."
    unzip -o fma_small.zip -d fma_small
}
fma_medium() {
    curl -O https://os.unil.cloud.switch.ch/fma/fma_medium.zip
    echo "c67b69ea232021025fca9231fc1c7c1a063ab50b  fma_medium.zip" | sha1sum -c -
    echo "Extracting fma_medium.zip..."
    unzip -o fma_medium.zip -d fma_medium
}
fma_large() {
    curl -O https://os.unil.cloud.switch.ch/fma/fma_large.zip
    echo "497109f4dd721066b5ce5e5f250ec604dc78939e  fma_large.zip" | sha1sum -c -
    echo "Extracting fma_large.zip..."
    unzip -o fma_large.zip -d fma_large
}
fma_full() {
    curl -O https://os.unil.cloud.switch.ch/fma/fma_full.zip
    echo "0f0ace23fbe9ba30ecb7e95f763e435ea802b8ab  fma_full.zip" | sha1sum -c -
    echo "Extracting fma_full.zip..."
    unzip -o fma_full.zip -d fma_full
}

# download metadata and the medium subset by default
fma_metadata
fma_medium

cd -