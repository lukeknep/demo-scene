#!/bin/bash

# Check if a file name is passed as an argument
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <filename>"
  exit 1
fi

filename="$1"

# Check if the file exists
if [ ! -f "$filename" ]; then
  echo "File does not exist."
  exit 1
fi

declare -A trade_numbers # Associative array to hold trade numbers and their occurrence counts
min_trade_number=0
max_trade_number=0
first_iteration=true

# Reading the file line by line
while IFS= read -r line
do
  # Parsing each line as a JSON object and extracting "trade_number"
  trade_number=$(echo "$line" | jq '.trade_number')

  # Check for minimum and maximum
  if [ "$first_iteration" = true ]; then
    min_trade_number=$trade_number
    max_trade_number=$trade_number
    first_iteration=false
  else
    if [ "$trade_number" -lt "$min_trade_number" ]; then
      min_trade_number=$trade_number
    fi
    if [ "$trade_number" -gt "$max_trade_number" ]; then
      max_trade_number=$trade_number
    fi
  fi

  # Record the occurrence of each trade number
  if [ -z "${trade_numbers[$trade_number]}" ]; then
    trade_numbers[$trade_number]=1
  else
    let "trade_numbers[$trade_number]++"
  fi

  if [ $((tradenumber % 1000)) -eq 0 ]; then 
    echo "parsed 1000 trades"
  fi
done < "$filename"

echo "Minimum Trade Number: $min_trade_number"
echo "Maximum Trade Number: $max_trade_number"

# Check for gaps and duplicates
expected_count=$((max_trade_number - min_trade_number + 1))
actual_count=${#trade_numbers[@]}

if [ "$actual_count" -ne "$expected_count" ]; then
  echo "There are gaps in the trade numbers."
else
  echo "There are no gaps in the trade numbers."
fi

duplicates_found=false
for count in "${trade_numbers[@]}"; do
  if [ "$count" -gt 1 ]; then
    duplicates_found=true
    break
  fi
done

if [ "$duplicates_found" = true ]; then
  echo "There are duplicates in the trade numbers."
else
  echo "There are no duplicates in the trade numbers."
fi
