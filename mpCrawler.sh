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
#Root dir for files
MP_DIR=$(echo ~)"/Music/marketplace/"
#REGEX to identify files

YEAR="[0-9][0-9][0-9][0-9]"
DAY="[0-3][0-9]"
MONTH="[0-1][1-9]"
DATE=${YEAR}${MONTH}${DAY}

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

resetTput=$(tput sgr0)

#### FUNCTIONS ####

#Functions for wrapping echo for color and STDERR
function echoerr {
    tput setaf 1
    echo "ERROR: "${@} 1>&2
    tput sgr0
}

function echowarn {
    tput setaf 3
    echo "WARNING: "${@}${resetTput}
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

#Builds part of the path (after the MP root dir) based on the
#   file name/date structure
#Example file:
#   marketplace_podcast_20140530_64.mp3
#@param:
#       $1: file to derive path
#
#@return: 
#       Path derived from file
#       "returned" via echo; call by subshell
function buildPath {
    local file=$1
    #get the date from the file name
    local fileDate=$(echo ${file} | grep -o -e ${DATE})
    local yr_mnth=${fileDate:0:4}"_"${fileDate:4:2}
    local day=${fileDate:6:2}
    echo "${yr_mnth}/${day}/"
}

#Builds part of the path with file name appended at the end
#Example file:
#   marketplace_podcast_20140530_64.mp3
#@param:
#       $1: file to derive path
#
#@return: 
#       Path derived from file
#       "returned" via echo; call by subshell
function buildPathName {
    local file=$1
    echo "$(buildPath ${file})${file}"
}

#Updates the logs to see if the user deleted some files
#   between runs; if they did we shouldn't attempt to download
#   the file again for them
#@param:
#
#@return: 
function updateLog {
    if [[ ! -f ${MP_DIR}${DL_LOG}  ]]; then
        echowarn "Log file missing. Making new log file now..."
        #Touch...I remember touch...picture came with touch...
        touch ${MP_DIR}${DL_LOG}
    else
        echo "Updating logs..."
        local fileList=$(<${MP_DIR}${DL_LOG})
        for file in "${fileList[@]}"; do
            echo $file
        done
    fi
}

#Checks to see if the file should be downloaded
#This is determined by looking in the logs to see if the file
#   was deleted by the user
#@param:
#       $1: file to check
#
#@return: 
#       0 for success; otherwise error code
#       "returned" via echo; call by subshell
function checkDL {
    local file=$1
    local bool=0
    #Don't download something we already have
    grep -o -q ${file} ${MP_DIR}${DL_LOG}
    if [[ $? = 0 ]]; then
        bool=1
    fi
    grep -o -q ${MRKDEL}${file} ${MP_DIR}${DL_LOG}
    if [[ $? = 0 ]]; then
        bool=2
    fi
    echo ${bool}
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
    echosucc "Starting to pull files from server..."
    #Loop over everything in the podcast manifest and download
    for file in "${fileNames[@]}"; do
        check=$(checkDL ${file})
        case ${check} in
            0)
                if [[ ! -d ${MP_DIR}$(buildPath ${file}) ]]; then
                    echowarn "Directory ~/$(buildPath ${file}) does not exist. Making structure now..."
                    mkdir -p ${MP_DIR}$(buildPath ${file})
                fi
                echo "Downloading ${file}..."
                wget -q -O ${MP_DIR}$(buildPathName ${file}) ${fileURL[${i}]}
                if [[ $? = 0 ]]; then
                    echo ${file} >> ${MP_DIR}${DL_LOG}
                else
                    echo ${MRKFAIL} >> ${MP_DIR}${DL_LOG}
                    let errCnt++
                fi
                ;;
            1)
                echosucc "File ${file} already saved"
                ;;
            2)
                echowarn "File ${file} was not downloaded b/c you deleted it"
                ;;
        esac
        let i++
    done
    #report back
    if [[ ${errCnt} = 0 ]]; then
        echosucc "Updating Completed Successfully"
    else
        echoerr "${errCnt} downloads failed"
    fi
}


####   MAIN    ####
function main {
    #Build base directory
    if [[ ! -d ${MP_DIR} ]]; then
        echowarn "${MP_DIR} does not exist. Making directory structure now..."
        mkdir -p ${MP_DIR}
    fi
    #check if the user
    updateLog
    #look for the latest files
    parseXML
    #pull down the new files
    pullFiles
}

main
