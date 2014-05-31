#!/bin/bash
#
#This script pulls the latest MarketPlace podcasts and organizes them
#Authors:
#
#   Schuyler Martin @schuylermartin45
#

#### CONSTANTS ####

#URL to the podcast manifest
MP_XML="http://www.marketplace.org/node/all/podcast.xml"
#REGEX to identify files

YEAR="[0-9][0-9][0-9][0-9]"
DAY="[0-3][0-9]"
MONTH="[0-1][1-9]"
DATE=${YEAR}${MONTH}${DAY}
EXT="\.mp3"
FILE_REGEX="\/${YEAR}\/${MONTH}\/${DAY}\/*${DATE}*${EXT}"

#To find all the url attributes
URL_REGEX='url=['"'"'"][^"'"'"']*['"'"'"]'
#Strips the front of the attribute
STRIP1='s/^url=["'"'"']//'
#Strips the back of the attribute
STRIP2='s/["'"'"']$//'

#Log for what's been downloaded before
DL_LOG=".mpLog"

####   VARS    ####

fileNames=()
fileURL=()

#### FUNCTIONS ####

#Parses podcast manifest into file names and URLs
function parseXML {
    #Take the xml file, extract the URLs, and put into an array
    fileURL=($(curl -s ${MP_XML} | grep -o -e ${URL_REGEX} \
        | sed -e ${STRIP1} -e ${STRIP2}))
    echo ${fileURL[1]}
    #local results=$(echo ${xml} | sed 's/.* url=\"\(.*\)\ .*"/\1/g')
    #echo ${results}
}

function pullFiles {
}


####   MAIN    ####
function main {
    parseXML
}

main
