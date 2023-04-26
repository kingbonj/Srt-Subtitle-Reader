#!/bin/bash

keypress=false
delay=1000
verbose=false

function cleanup {
  # Remove the temporary .txt file
  rm "${filename%.*}.txt"
  echo ""
  echo "Program terminated by user."
  exit 1
}

trap cleanup SIGINT

while getopts ":kt:vh" opt; do
  case $opt in
    k)
      keypress=true
      ;;
    t)
      delay=$OPTARG
      ;;
    v)
      verbose=true
      ;;
    h)
      echo "Usage: subtitle_display.sh [-k] [-t delay] [-v] file.srt"
      echo "Displays the contents of a subtitle file (.srt) with a specified delay between each line."
      echo ""
      echo "Options:"
      echo "  -k              Pause after each line of text and wait for user input."
      echo "  -t delay        Set the delay (in milliseconds) between each line of text (default: 1000)."
      echo "  -v              Verbose mode. Print additional information about the input file and runtime."
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

shift $((OPTIND - 1))

filename=$1

if [[ ! -f $filename ]]; then
  echo "File not found!"
  exit 1
fi

total_lines=$(tr -d '\r' < "$filename" | sed '/^[0-9]/d' | wc -l)
if [ "$verbose" = true ]; then
  echo "Input file: $filename"
  echo "Total lines: $total_lines"
  echo "Input delay: $delay milliseconds"
  runtime=$(($total_lines * $delay / 1000))
  printf "Estimated runtime: %02d:%02d:%02d\n" $(($runtime/3600)) $(($runtime%3600/60)) $(($runtime%60))
  echo "Additional parameters: ${@:2}"
fi

# Convert .srt to .txt file and filter out lines that start with numbers
tr -d '\r' < "$filename" | sed -E 's/<[^>]*>//g' | sed '/^[0-9]/d' > "${filename%.*}.txt"

# Read the .txt file line by line and display the text with a specified delay
previous_line=""
line_number=1
while read -r line; do
  if [[ $line =~ ^- ]]; then
    line=${line#- }
  fi
  if [[ $line =~ ^[[:lower:]] ]]; then
    # Combine the current line with the previous line
    if [[ $previous_line =~ ^[[:print:]]+$ ]]; then
      previous_line="$previous_line $line"
    else
      previous_line="$line"
    fi
  else
    # Display the previous line (if it exists)
    if [[ $previous_line =~ ^[[:print:]]+$ ]]; then
      if [ "$verbose" = true ]; then
        printf "%04d/%04d: \"%s\"\n" "$line_number" "$total_lines" "$previous_line"
      else
        printf "\"%s\"\n" "$previous_line"
      fi
      ((line_number++))
      if [ "$keypress" = true ] && [ "$line_number" -gt 2 ]; then
        read -n 1 -s -r -p "Press any key to continue..."
      else
        sleep "$(echo "$delay/1000" | bc -l)"
      fi
    fi
    previous_line="$line"
  fi
done < "${filename%.*}.txt"

# Display the last line (if it exists)
if [[ $previous_line =~ ^[[:print:]]+$ ]]; then
  if [ "$verbose" = true ]; then
    printf "%04d/%04d: \"%s\"\n" "$line_number" "$total_lines" "$previous_line"
  else
    printf "\"%s\"\n" "$previous_line"
  fi
  if [ "$keypress" = true ]; then
    if [ "$line_number" -gt 2 ]; then
      read -n 1 -s -r -p "Press any key to exit..."
    else
      sleep "$(echo "$delay/1000" | bc -l)"
    fi
  fi
fi

# Exit text:
  echo "Input file $filename completed with $total_lines parsed"

# Remove the temporary .txt file
rm "${filename%.*}.txt"

