#!/bin/bash

# Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# Variables
file_name="bundle.js"
file_name_temp="temp_${file_name}"
main_url="https://htbmachines.github.io/${file_name}"

# Pointers
declare -i parameter_counter=0

# Functions
function ctrl_c() {
  echo -e "\n\n${redColour}[!] Exiting...${endColour}\n"
  tput cnorm
  exit 1
}

function help_panel() {
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Usage:${endColour}"
  echo -e "\t${purpleColour}h)${endColour} ${grayColour}Show help panel.${endColour}"
  echo -e "\t${purpleColour}m)${endColour} ${grayColour}Search by machine name.${endColour}"
  echo -e "\t${purpleColour}u)${endColour} ${grayColour}Download or update necessary files.${endColour}"
  echo -e "\n"
}

function update() {
  tput civis

  if [ ! -f ${file_name} ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Downloading necessary files...${endColour}"
    curl -s ${main_url} > ${file_name}
    js-beautify -f ${file_name} | sponge ${file_name}
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}All files have been downloaded.${endColour}\n"
  else
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Checking for updates...${grayColour}"
    curl -s ${main_url} > ${file_name_temp}
    js-beautify -f ${file_name_temp} | sponge ${file_name_temp}
    md5_temp_value=$(md5sum ${file_name_temp} | awk '{print $1}')
    md5_value=$(md5sum ${file_name} | awk '{print $1}')

    if [ "${md5_value}" == "${md5_temp_value}" ]; then
      rm ${file_name_temp}
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Already up to date.${endColour}\n"
    else
      rm ${file_name} && mv ${file_name_temp} ${file_name}
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}All files have been updated.${endColour}\n"
    fi
  fi

  tput cnorm
}

function search_machine() {
  machine_name="$1"
  echo "$machine_name"
}

# Execution
trap ctrl_c INT

while getopts "m:uh" arg; do
  case $arg in
  m)
    machine_name=$OPTARG;
    parameter_counter+=1
    ;;
  u)
    parameter_counter+=2
    ;;
  h)
    ;;
  *)
    ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  search_machine "$machine_name"
elif [ $parameter_counter -eq 2 ]; then
  update
else
  help_panel
fi