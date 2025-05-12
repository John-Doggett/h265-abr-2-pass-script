# h265-abr-2-pass-script
Bash script to transcode video to h265 using libx265 with 2 pass average bit rate

Usage: ./transcode-to-h265.sh [input-directory] [output-directory] [input-extension] [bitrate] [optional-resolution]

Example (scale): ./transcode-to-h265.sh ./input ./output .mp4 10M 1280x720

Example (keep resolution): ./transcode-to-h265.sh ./input ./output .mp4 10M
