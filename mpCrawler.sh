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

#Markings
#Deletion
MRKDEL="XXX_"
#Failed to download
MRKFAIL="FAIL_"

####   VARS    ####

fileNames=()
fileURL=()

#### FUNCTIONS ####

#Functions for wrapping echo for color and STDERR
resetTput=$(tput sgr0)

function echoerr {
    tput setaf 1
    echo ${@}${restTput} 1>&2
}

function echosucc {
    tput setaf 2
    echo ${@}${resetTput}
}

#Parses podcast manifest into file names and URLs
#@param:
#
#@return: 
#       fileNames Array of file Names
#       fileURL Array of file URLs
function parseXML {
    #Take the xml file, extract the URLs, and put into an array
    fileURL=($(curl -s ${MP_XML} | grep -o -e ${URL_REGEX} \
        | sed -e ${STRIP1} -e ${STRIP2}))
    for file in "${fileURL[@]}"; do
        fileNames+=($(basename "${file}"))
    done
}

#Pulls the files from the site, using wget
#@param:
#
#@return: 
#       fileNames Array of file Names
#       fileURL Array of file URLs
function pullFiles { 
    i=0
    #count errors
    errCnt=0
    #Loop over everything in the podcast manifest and download
    for file in "${fileNames[@]}"; do
        echo "Downloading ${file}..."
        wget -q -O ${file} ${fileURL[${i}]}
        if [[ $? = 0 ]]; then
            echo ${file} >> ${DL_LOG}
        else
            echo ${MRKFAIL} >> ${DL_LOG}
            let errCnt++
        fi
        let i++
    done
    #report back
    if [[ ${errCnt} = 0 ]]; then
        echosucc "Updating Completed Successfully"
    else
        echoerr "ERROR: ${errCnt} downloads failed"
    fi
}


####   MAIN    ####
function main {
    parseXML
    pullFiles
}

main
