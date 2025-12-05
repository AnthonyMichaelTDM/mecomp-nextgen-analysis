#!/bin/bash

# Given 3 track IDs, play the corresponding audio files in sequence
# wait for user input between each playback
# Usage: ./play_triplet.sh <anchor_id> <positive_id> <negative_id>
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <anchor_id> <positive_id> <negative_id>"
    exit 1
fi

ANCHOR_ID=$1
POSITIVE_ID=$2
NEGATIVE_ID=$3

# zero-pad the IDs to 6 digits
ANCHOR_ID=$(printf "%06d" "${ANCHOR_ID:0:6}")
POSITIVE_ID=$(printf "%06d" "${POSITIVE_ID:0:6}")
NEGATIVE_ID=$(printf "%06d" "${NEGATIVE_ID:0:6}")

DATA_DIR="../data/fma_small"
ANCHOR_FILE="${DATA_DIR}/${ANCHOR_ID:0:3}/${ANCHOR_ID}.mp3"
POSITIVE_FILE="${DATA_DIR}/${POSITIVE_ID:0:3}/${POSITIVE_ID}.mp3"
NEGATIVE_FILE="${DATA_DIR}/${NEGATIVE_ID:0:3}/${NEGATIVE_ID}.mp3"

echo "Playing anchor track (ID: $ANCHOR_ID)..."
ffplay -nodisp -autoexit "$ANCHOR_FILE"
read -p "Press enter to play positive track (ID: $POSITIVE_ID)..."
ffplay -nodisp -autoexit "$POSITIVE_FILE"
read -p "Press enter to play negative track (ID: $NEGATIVE_ID)..."
ffplay -nodisp -autoexit "$NEGATIVE_FILE"