#!/bin/bash
# Author: Jon Machtynger
# Date: 28/02/2019
#
# Script to extract keyframes from video to use for Video search using CNNs
# It simply requires a valid video file and will create a directory containing the keyframes as jpgs

usage() { echo "Usage: $0 -i <video input> [-d <directory>]" 1>&2; exit 1; }

DIR="."		# If you don't specify a directory, then use the current one
while getopts ":i:d:" o; do
    case "${o}" in
        i) # Name of the video file to process
            FNAME=${OPTARG}; echo "Setting FNAME to $FNAME"
            ;;
        d) # Name of the parent directory to dump the keyframe directory
            DIR=${OPTARG} ; echo "Setting DIR to $DIR"
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ ! -e "${FNAME}" ] ; then
    echo "The source video '$FNAME' doesn't exist"
    usage
fi

# Define a directory to hold all keyframes based on the original movie file name
# Try various - bash substitution does not support (a|b|c) so need to do individually
IMGDIR="${FNAME/\.mp4/IMGS}"
if [ $IMGDIR = $FNAME ];then
	IMGDIR="${FNAME/\.mpg/IMGS}"
fi
if [ $IMGDIR = $FNAME ];then
	IMGDIR="${FNAME/\.avi/IMGS}"
fi
echo "IMGDIR = ${IMGDIR}"

echo "Making directory ${DIR}/$IMGDIR}"
mkdir ${DIR}/$IMGDIR

# Determine the resolution from the file to be analysed
RESOLUTION=`ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 $FNAME`
# Use that resolution for the keyframes so they're not distorted
ffmpeg -i $FNAME -vf select='eq(pict_type\,I)' -vsync 2 -q 1 -s $RESOLUTION -f image2 $DIR/${IMGDIR}/kf-%02d.jpg

