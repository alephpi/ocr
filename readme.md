# OCR workflow

procedure

- Given (scanned) pdf
  1. pagination
  1. convert pdf to image
  1. OCR image to text
  1. merge texts in one

dependency: pdftk, ghostscript, tesseract

usage

```
./run.sh <input_pdf> -l <language>
```
