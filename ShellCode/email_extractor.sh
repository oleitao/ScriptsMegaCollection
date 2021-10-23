#!/bin/bash

echo "Merging all data..."
find . -type f -name '*.html' -exec cat {} + >> output.file
echo "Extracting all emails..."
egrep -o "\b[a-zA-Z0-9.-]+@[a-zA-Z0-9.-]+.[a-zA-Z0-9.-]+\b" output.file >> text.txt
rm output.file
echo "Removing duplicated emails..."
cat text.txt | sort | uniq >> emails.txt
rm text.txt
echo "All emails extracted successfully."
