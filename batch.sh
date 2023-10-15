#!/bin/bash

# Check if FFmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "FFmpeg is not installed. Please install it first."
    exit 1
fi

# Check if ExifTool is installed
if ! command -v exiftool &> /dev/null; then
    echo "ExifTool is not installed. Please install it first."
    exit 1
fi

# Input directory
input_dir="set_input_dir_here"

# Output directory
output_dir="set_output_dir_here"

# Check if the output directory exists; create it if not
if [ ! -d "$output_dir" ]; then
    mkdir -p "$output_dir"
fi

# Iterate over the files in the input directory
for input_file in "$input_dir"/*; do
    # Check if the file is a regular file
    if [ -f "$input_file" ]; then
        # Get the file name (without path)
        file_name=$(basename "$input_file")
        
        # Set the path for the output file in the output directory
        output_file="$output_dir/$file_name"
        
        # Get the original creation date of the input file
        creation_date=$(stat -c %y "$input_file")
        
        # Perform the H.264 conversion while preserving the creation date and scaling to 1920 pixels wide
        ffmpeg -i "$input_file" -vf "scale=1920:-2" -c:v libx264 -crf 23 -c:a aac -strict experimental "$output_file"
        
        # Set the original creation date for the output file using ExifTool
        exiftool -TagsFromFile "$input_file" "-FileCreateDate>FileModifyDate" -overwrite_original "$output_file"
        
        echo "Conversion of $file_name to H.264 with scaling to 1920 pixels wide and original creation date preserved completed."
    fi
done

echo "Batch processing completed."
