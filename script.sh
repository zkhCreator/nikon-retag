#!/bin/bash

# Check if the tag tool is installed
if ! command -v tag &> /dev/null; then
  echo "The tag tool is not installed. Please install it using the following command:"
  echo "brew install tag"
  exit 1
fi

# Define the directory to process
DIR=$1

# Check if the directory exists
if [ ! -d "$DIR" ]; then
  echo "Directory does not exist: $DIR"
  exit 1
fi

# Iterate over all JPG files
for jpg_file in "$DIR"/*.JPG; do
  # Check if the file exists
  if [ ! -f "$jpg_file" ]; then
    continue
  fi

  # Get the file name without extension
  filename=$(basename -- "$jpg_file")
  filename="${filename%.*}"

  # Get the tags of the JPG file, extracting only the tags part
  tags=$(tag -Nl "$jpg_file" | tr ',' ' ')

  # Print debug information
  echo "Checking $jpg_file, tags: $tags"

  # If the JPG file has tags, process it
  if [ -n "$tags" ]; then
    # Check if the corresponding NEF file exists
    nef_file="$DIR/$filename.NEF"
    if [ -f "$nef_file" ]; then
      # Add tags to the NEF file
      tag --add "$tags" "$nef_file"
      echo "Added tags to $nef_file: $tags"

      # Remove tags from the JPG file
      tag --remove "$tags" "$jpg_file"
      echo "Removed tags from $jpg_file: $tags"
    else
      echo "NEF file not found: $nef_file"
    fi
  fi
done
