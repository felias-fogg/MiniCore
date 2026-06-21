#!/bin/bash

AUTHOR=MCUdude   # Github username
REPOSITORY=MiniCore # Github repo name

GCC_VERSION="15.1.0"
MC_VERSION="4.0.0"
MC_PATCH_LEVEL="52"
PATCH_LEVEL="01"
ARDUINO_VERSION=${GCC_VERSION}-microchip${MC_VERSION}-${PATCH_LEVEL}

OS_PLATFORM1="linux.any.x86_64"
OS_PLATFORM2="win32.any.x86_64"
OS_PLATFORM3="darwin.any.universal"

HOST1="x86_64-linux-gnu"
HOST2="x86_64-mingw32"
HOST3="x86_64-apple-darwin"
HOST4="arm64-apple-darwin"

FILE1=avr8-gnu-toolchain-${MC_VERSION}.${MC_PATCH_LEVEL}-${OS_PLATFORM1}.tar.gz
FILE2=avr8-gnu-toolchain-${MC_VERSION}.${MC_PATCH_LEVEL}-${OS_PLATFORM2}.zip
FILE3=avr8-gnu-toolchain-${MC_VERSION}.${MC_PATCH_LEVEL}-${OS_PLATFORM3}.tar.gz

URL1=https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/SoftwareTools/${FILE1}
URL2=https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/SoftwareTools/${FILE2}
URL3=https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/SoftwareTools/${FILE3}

# Download files
wget --no-verbose $URL1
wget --no-verbose $URL2
wget --no-verbose $URL3

SIZE1=$(wc -c $FILE1 | awk '{print $1}')
SIZE2=$(wc -c $FILE2 | awk '{print $1}')
SIZE3=$(wc -c $FILE3 | awk '{print $1}')

SHASUM1=$(shasum -a 256 $FILE1 | awk '{print "SHA-256:"$1}')
SHASUM2=$(shasum -a 256 $FILE2 | awk '{print "SHA-256:"$1}')
SHASUM3=$(shasum -a 256 $FILE3 | awk '{print "SHA-256:"$1}')

printf "File1: ${FILE1}, Size: ${SIZE1}, SHA256: ${SHASUM1}, URL1: ${URL1}\n"
printf "File2: ${FILE2}, Size: ${SIZE2}, SHA256: ${SHASUM2}, URL2: ${URL2}\n"
printf "File3: ${FILE3}, Size: ${SIZE3}, SHA256: ${SHASUM3}, URL3: ${URL3}\n"

cp "package_${AUTHOR}_${REPOSITORY}_index.json" "package_${AUTHOR}_${REPOSITORY}_index.json.tmp"

jq -r                                  \
--arg arduino_version $ARDUINO_VERSION \
--arg host1       $HOST1        \
--arg host2       $HOST2        \
--arg host3       $HOST3        \
--arg host4       $HOST4        \
--arg file1       $FILE1        \
--arg file2       $FILE2        \
--arg file3       $FILE3        \
--arg file4       $FILE3        \
--arg size1       $SIZE1        \
--arg size2       $SIZE2        \
--arg size3       $SIZE3        \
--arg size4       $SIZE3        \
--arg shasum1     $SHASUM1      \
--arg shasum2     $SHASUM2      \
--arg shasum3     $SHASUM3      \
--arg shasum4     $SHASUM3      \
--arg url1        $URL1         \
--arg url2        $URL2         \
--arg url3        $URL3         \
--arg url4        $URL3         \
'.packages[].tools[.packages[].tools | length] |= . +
{
  "name": "avr-gcc",
  "version": $arduino_version,
  "systems": [
    {
      "size": $size1,
      "checksum": $shasum1,
      "host": $host1,
      "archiveFileName": $file1,
      "url": $url1
    },
    {
      "size": $size2,
      "checksum": $shasum2,
      "host": $host2,
      "archiveFileName": $file2,
      "url": $url2
    },
    {
      "size": $size3,
      "checksum": $shasum3,
      "host": $host3,
      "archiveFileName": $file3,
      "url": $url3
    },
    {
      "size": $size4,
      "checksum": $shasum4,
      "host": $host4,
      "archiveFileName": $file4,
      "url": $url4
    }
  ]
}' "package_${AUTHOR}_${REPOSITORY}_index.json.tmp" > "package_${AUTHOR}_${REPOSITORY}_index.json"

rm $FILE1
rm $FILE2
rm $FILE3
rm "package_${AUTHOR}_${REPOSITORY}_index.json.tmp"
