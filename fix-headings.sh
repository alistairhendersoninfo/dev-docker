#!/bin/bash

# Fix MD022 linting errors - ensure headings have blank lines above and below
# Usage: ./fix-headings.sh filename.md

if [[ $# -eq 0 ]]; then
    echo -n "Enter markdown filename: "
    read -r filename
else
    filename="$1"
fi

if [[ ! -f "$filename" ]]; then
    echo "Error: File '$filename' not found"
    exit 1
fi

# Create temporary file
temp_file=$(mktemp)

# Process file line by line
while IFS= read -r line; do
    # If line starts with ### (heading)
    if [[ "$line" =~ ^### ]]; then
        # Add blank line above heading (if not already there)
        if [[ -n "$prev_line" && "$prev_line" != "" ]]; then
            echo "" >> "$temp_file"
        fi
        # Add heading
        echo "$line" >> "$temp_file"
        # Add blank line below heading
        echo "" >> "$temp_file"
    else
        # Regular line - just add it
        echo "$line" >> "$temp_file"
    fi
    prev_line="$line"
done < "$filename"

# Replace original file
mv "$temp_file" "$filename"

echo "Fixed headings in $filename"
