#!/bin/bash

# Check arguments
if [[ $# -lt 4 || $# -gt 5 || "$1" == "$2" ]]; then
    echo "Usage: $0 [input-directory] [output-directory] [input-extension] [bitrate] [optional-resolution]"
    echo "Example (scale): $0 ./input ./output .mp4 10M 1280x720"
    echo "Example (keep resolution): $0 ./input ./output .mp4 10M"
    exit 1
fi

# Parameters
INPUT_DIR="$1"
OUTPUT_DIR="$2"
INPUT_EXT="$3"
BITRATE="$4"
RESOLUTION="${5:-}"  # Optional

# Create output directory if needed
mkdir -p "$OUTPUT_DIR"

# Loop over input files
for infile in "$INPUT_DIR"/*"$INPUT_EXT"; do
    [ -e "$infile" ] || continue

    filename=$(basename "$infile")
    name="${filename%$INPUT_EXT}"

    outfile="$OUTPUT_DIR/${name}.mkv"
    log_file="${name}_2pass.log"

    echo "Encoding: $filename -> $outfile"

    # Optional scaling filter
    SCALE_FILTER=""
    if [[ -n "$RESOLUTION" ]]; then
        echo "Applying resolution: $RESOLUTION"
        SCALE_FILTER="-vf scale=$RESOLUTION"
    fi

    # First pass
    ffmpeg -y -i "$infile" $SCALE_FILTER \
        -c:v libx265 -b:v "$BITRATE" \
        -x265-params "pass=1:stats=$log_file" -preset slower -an -f null /dev/null

    # Second pass
    ffmpeg -i "$infile" $SCALE_FILTER \
        -c:v libx265 -b:v "$BITRATE" \
        -x265-params "pass=2:stats=$log_file" -preset slower -c:a copy -c:s copy "$outfile"

    rm -f "$log_file"
    echo "Finished: $outfile"
done
