#!/bin/bash

# Fix MD022 linting errors - ensure headings have blank lines above and below
# Usage: ./fix-headings.sh filename.md
# 
# Features:
# - Handles both ## and ### headings
# - Only adds blank lines when needed (prevents double blank lines)
# - Removes double blank lines if they exist

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

echo "Processing headings in $filename..."

# Read file into array
mapfile -t lines < "$filename"

# Process the file
{
    for i in "${!lines[@]}"; do
        line="${lines[$i]}"
        
        # Check if current line is a heading
        if [[ "$line" =~ ^##+ ]]; then
            # Check previous line for blank line before heading
            if [[ $i -gt 0 ]]; then
                prev_line="${lines[$((i-1))]}"
                if [[ -n "$prev_line" ]]; then
                    echo ""  # Add blank line before heading
                fi
            fi
            
            # Output the heading
            echo "$line"
            
            # Check next line for blank line after heading
            if [[ $i -lt $((${#lines[@]}-1)) ]]; then
                next_line="${lines[$((i+1))]}"
                if [[ -n "$next_line" ]]; then
                    echo ""  # Add blank line after heading
                fi
            fi
        else
            # For non-heading lines, output them normally
            echo "$line"
        fi
    done
} > "$filename.tmp"

# Remove consecutive blank lines
awk '!NF {if (++n <= 1) print; next}; {n=0;print}' "$filename.tmp" > "$filename"

# Clean up
rm -f "$filename.tmp"



echo "✅ Fixed headings in $filename"
echo "   - Ensured blank lines above and below ## and ### headings"
echo "   - Removed double blank lines"
