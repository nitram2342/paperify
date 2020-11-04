#!/bin/bash -e

chunk_size=2953
error_correction_level=L

for (( i=1; i<=$#; i++ ))
do
  if [ "${!i}" = "-c" ]
  then
    comment=${!i};
  elif [ "${!i}" = "-L" ]
  then
      :
  elif [ "${!i}" = "-M" ]
  then
       chunk_size=2331
       error_correction_level=M
  elif [ "${!i}" = "-Q" ]
  then
       chunk_size=1663
       error_correction_level=Q
  elif [ "${!i}" = "-H" ]
  then
       chunk_size=1273
       error_correction_level=H
  elif [ "${!i}" = "-h" ]
  then
    echo "usage: paperify.sh [OPTIONS] <FILE>"
    echo ""
    echo "options:"
    echo -e "  -h\t\t\tShow this help."
    echo -e "  -L|-M|-Q|-H\t\tQR code error correction level.."
    echo -e "  -c COMMENT\t\tAdd comment to the generated files."
    exit 0
  else
    file="$INPUT_DIR${!i}";
  fi

done

if test -f "${file}"; then
  echo "Paperifying ${file}"
else
  echo "File not found! ${file}"
  exit 1
fi

filename=$(echo "${file}" | rev | cut -f 1 -d '/' | rev)
prefix="$filename-"
dir="${OUTPUT_DIR}${filename}-qr"

rm -Rf -- "${dir}"
mkdir -p "${dir}"

sha=$(sha1sum "${file}" | cut -f 1 -d ' ')
date=$(date -u +%Y-%m-%dT%H:%M:%S+00:00)

cat "${file}" | split -d -b ${chunk_size} -a3 - "${dir}/${prefix}"

cd "${dir}"

count=$(ls | wc -l)
FONT=${FONT:-fixed}

for f in *
do
  echo "Processing ${f}"
  chunksha=$(sha1sum "${f}" | cut -f 1 -d ' ')

  out="_${f/\ /_}.png"
  cat "${f}" | qrencode --8bit -v 40 --size=13 --margin=1 -l L --output "${out}"

  convert -size 2863x4036 xc:white \( "${out}" -gravity center \) -composite \
    -font "${FONT}" -pointsize 72 -gravity northwest -annotate +100+200 "FILE: ${filename}\n\nCHUNK: ${f}\n\nTOTAL CHUNKS/PAGES: ${count}" \
    -gravity southwest -pointsize 41 -annotate +100+300 "CHUNK ${f##*-} SHA1: ${chunksha}\n\nFINAL SHA1: ${sha}" \
    -gravity northeast -pointsize 41 -annotate +100+130 "${date}" \
    -gravity southeast -pointsize 41 -annotate +100+150 "${comment}" \
    -gravity southwest -pointsize 41 -annotate +100+150 "github.com/nitram2342/paperify (chunksize: ${chunk_size})" "${out}"

  convert "${out}" "${out}.pdf"
  if [ -f "${f}" ]; then
      rm "${f}"
  fi
done

# join pdf files, 
if ! gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite "-sOutputFile=${filename}.pdf" _*.pdf
then
    echo Program gs (ghostscript) not found. Try to use pdfunite.
    if ! pdfunite _*.pdf "${filename}.pdf"
    then
	echo Failed to execute pdfunite, too. Please install it
	exit
    fi
    
fi
rm _*.pdf

echo ""
echo "QR Code generation completed."
echo "You can now print file: $dir/${filename}.pdf"
