#!/bin/bash

# Set the input PDF from the first argument and the language from the -l flag
input_pdf="$1"
language="eng"  # Default language code for English

# Process optional -l flag for language
while getopts ":l:" opt; do
    case $opt in
        l) language="$OPTARG";;
        \?) echo "Invalid option -$OPTARG"; exit 1;;
    esac
done

# Check if the input PDF file is provided
if [ -z "$input_pdf" ]; then
    echo "Usage: $0 <input_pdf> [-l <language>]"
    exit 1
fi

# Create a variable for the working folder with a timestamp
working_folder="working_folder_$(date +%Y%m%d%H%M%S)"

# Create the working folder
mkdir "$working_folder"
mkdir "$working_folder/pdf"
mkdir "$working_folder/img"
mkdir "$working_folder/txt"

# Burst the PDF into individual pages
pdftk "$input_pdf" burst output "$working_folder/pdf/page_%04d.pdf"

# Convert PDF pages to PNG images
gs -dNOPAUSE -sDEVICE=pnggray -r300 -o "$working_folder"/img/page_%04d.png "$working_folder"/pdf/page_*.pdf

# Perform OCR using Tesseract for each PNG image
for image_path in "$working_folder"/img/*.png; do
    # Get the image filename without extension
    image_name=$(basename -- "${image_path%.*}")

    # Perform OCR using Tesseract
    tesseract "$image_path" "$working_folder/txt/$image_name" -l "$language"

    echo "Processed: $image_path"
done

echo "OCR batch processing completed."

# Create the output file
output_file="$input_pdf.txt"

# Merge the text files in numerical order based on the filenames
cat "$working_folder"/txt/page_*.txt | tr '\f' '\n' > "$output_file"
echo "Text files merged and saved to $output_file."