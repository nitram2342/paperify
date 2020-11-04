# Paperify

[![CircleCI](https://circleci.com/gh/alisinabh/paperify.svg?style=svg)](https://circleci.com/gh/alisinabh/paperify)

Use QR codes to backup your data on papers. Simply backup your files, print them and store them in a safe place.

## Sample

![Paperify](paperify.png)

## Requirements

Make sure you have these binaries installed on your system.

 - `qrencode` (qrencode)
 - `convert` (imagemagick)
 - ``gs` (ghostscript) or `pdfunite` to combine QR code images to a PDF for easier printing.
 - `zbarimg` (zbar >= 0.23.1) __only for decoding with digitallify.sh__
 - `scanimage` (sane-utils) __only as a helper for scanning images__
 
**Zbar**: Binary support is just added in zbar `0.23.1` and not supported in earlier versions.
Please verify that your zbar version is higher or equal to `0.23.1`. You can do that by running 
```
zbarimg --version
0.23.1
```
You can download and build zbar from [github.com/mchehab/zbar/](https://github.com/mchehab/zbar/).
Note that zbar is **not** required for `paperify.sh` It is only required for `digitallify.sh` decoding.

## Installation

These are just bash scripts. There is no need to install them.

You can either use git to clone this repo or download it in zip.

```
git clone https://github.com/alisinabh/paperify.git && cd paperify
# --- OR ---
wget https://github.com/alisinabh/paperify/archive/master.zip -O paperify.zip && \
     unzip paperify.zip && cd paperify-master
```

Or you can use paperify's Docker image at alisinabh/paperify. More details below.

## Usage

### Backup

Creates `FILE-qr` directory with generated QR codes and a PDF file (if possible) inside.
Then you can print those files and keep them. If you want to increase the error correction
level use option `-L` (default, low error correction level, 2953 bytes per page, 7 % can
be restored), `-M` (2331 bytes per page, 15 % can be restored), `-Q` (1663 bytes per page,
25 % of data can be restored), or `-H` (highest error correction level, 1273 bytes per
page, 30% of data can be restored).

```
./paperify.sh [options] FILE
```


### Restore

Scan your pages. If you use SANE tools, you can use the script `scanimages.sh` which scans page by page.
Afterwards, use `digitalify.sh` to parse QR codes in all image files from `DIRECTORY` and to reconstruct
chunks into `OUTPUT_FILE`. Make sure input file names are correct. 

```
./digitalify.sh OUTPUT_FILE DIRECTORY
```

Finally, verify the SHA-1 sum.

### Use with Docker

You can mount your files at `/target` in paperify's docker container. Then run paperify.

For simplicity, You can just copy the bellow commands which will mount your current directory automatically.

```
# To Paperify
# FIRST: cd into the folder that your file is in
docker run -v$(pwd):/target alisinabh/paperify FILE

# To Digitallify
# First cd into the folder that your scanned images are in
docker run -v$(pwd):/target --entrypoint=/paperify/digitallify.sh alisinabh/paperify OUTPUT_FILE .
```

## Recommendations

### Multiple files

Use tarballs and gzip to store and compress your data.
```
tar cvfz files.tgz file1.txt file2.txt
```

### Encryption

To protect your data you can encrypt them using `gpg` (GnuPG).
```
gpg --symmetric file.txt
```
Then use `file.txt.gpg` in paperify. 

## License
Peperify is licensed in GPL-3.0

Read more in [LICESE](LICENSE)
