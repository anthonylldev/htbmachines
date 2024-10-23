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
path_file_temp="/tmp/htbmachines/${file_name}"
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
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Usage:${endColour}\n"
  echo -e "\t${purpleColour}h)${endColour} ${grayColour}Show help panel.${endColour}"
  echo -e "\t${purpleColour}u)${endColour} ${grayColour}Download or update necessary files.${endColour}"
  echo -e "\t${purpleColour}l)${endColour} ${grayColour}List machines${endColour}"
  echo -e "\t${purpleColour}y)${endColour} ${grayColour}Get link of the machine resolution by machine name.${endColour}"
  echo -e "\t${purpleColour}m)${endColour} ${grayColour}Search by machine name.${endColour}"
  echo -e "\t${purpleColour}i)${endColour} ${grayColour}Search by ip address.${endColour}"
  echo -e "\t${purpleColour}d)${endColour} ${grayColour}Search by difficulty:${endColour}"
  echo -e "\t\t${turquoiseColour}1${endColour} ${grayColour}- Easy${endColour}"
  echo -e "\t\t${turquoiseColour}2${endColour} ${grayColour}- Normal${endColour}"
  echo -e "\t\t${turquoiseColour}3${endColour} ${grayColour}- Difficult${endColour}"
  echo -e "\t\t${turquoiseColour}4${endColour} ${grayColour}- Insane${endColour}"
  echo -e "\t${purpleColour}o)${endColour} ${grayColour}Search by os:${endColour}"
  echo -e "\t\t${turquoiseColour}1${endColour} ${grayColour}- Linux${endColour}"
  echo -e "\t\t${turquoiseColour}2${endColour} ${grayColour}- Windows${endColour}\n"
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
    curl -s ${main_url} > ${path_file_temp}
    js-beautify -f ${path_file_temp} | sponge ${path_file_temp}
    md5_temp_value=$(md5sum ${path_file_temp} | awk '{print $1}')
    md5_value=$(md5sum ${file_name} | awk '{print $1}')

    if [ "${md5_value}" == "${md5_temp_value}" ]; then
      rm ${path_file_temp}
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Already up to date.${endColour}\n"
    else
      rm ${file_name} && mv ${path_file_temp} ./
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}All files have been updated.${endColour}\n"
    fi
  fi

  tput cnorm
}

function list() {
  echo -e "\n${blueColour}$(process_list | head -n 1)${endColour}"
  echo -e "${grayColour}$(process_list | sed '1d')${endColour}\n"
}

function get_youtube_link() {
  machine_name=$1
  link=$(cat ${file_name} | awk "/name: \"${machine_name}\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep "youtube:" | awk 'NF{print $NF}')

  if [ "${link}" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Machine with name${endColour} ${blueColour}${machine_name}${endColour} ${grayColour}is resolved in${endColour} ${greenColour}${link}${endColour}\n"
  else
    echo -e "\n${redColour}[!] Machine with name${endColour} ${blueColour}${machine_name}${endColour} ${redColour}not found.${endColour}\n"
  fi
}

function search() {
  machine_name=$1
  ip_address=$2
  difficulty=$3
  os=$4
  result=$(process_list | sed '1,2d')


  echo "${machine_name}"

  if [ "${machine_name}" ]; then
    to_evaluate=$(echo "${result}" | awk '{print $1}' | grep "${machine_name}")

    if [ "${to_evaluate}" ]; then
      result=$(echo "${result}" | grep "${to_evaluate}")
    else
      result=""
    fi
  fi

  if [ "${ip_address}" ]; then
    result=$(echo "${result}" | grep "${ip_address}")
  fi

  if [ "${difficulty}" ]; then
    case $3 in
    1)
      level="Easy"
      ;;
    2)
      level="Normal"
      ;;
    3)
      level="Difficult"
      ;;
    4)
      level="Insane"
      ;;
    *)
      show_difficulty_message
      exit 1
    esac

    result=$(echo "${result}" | grep "${level}")
  fi

  if [ "${os}" ]; then
    case $4 in
    1)
      os_label="Linux"
      ;;
    2)
      os_label="Windows"
      ;;
    *)
      show_os_message
      exit 1
    esac

    result=$(echo "${result}" | grep "${os_label}")
  fi

  if [ "${result}" ]; then
    echo -e "\n${blueColour}$(process_list | head -n 1)${endColour}"
    echo -e "${grayColour}$(process_list | head -n 2 | tail -n 1)${endColour}"
    echo -e "${grayColour}${result}${endColour}\n"
  else
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}No elements found.${endColour}\n"
  fi
}

function show_difficulty_message() {
  echo -e "${redColour}[!] The difficulty entered is not valid.${endColour}"
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Please select one of these:${endColour}"
  echo -e "\t${turquoiseColour}1${endColour} ${grayColour}- Easy${endColour}"
  echo -e "\t${turquoiseColour}2${endColour} ${grayColour}- Normal${endColour}"
  echo -e "\t${turquoiseColour}3${endColour} ${grayColour}- Difficult${endColour}"
  echo -e "\t${turquoiseColour}4${endColour} ${grayColour}- Insane${endColour}\n"
}

function show_os_message() {
  echo -e "${redColour}[!] The os entered is not valid.${endColour}"
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Please select one of these:${endColour}"
  echo -e "\t${turquoiseColour}1${endColour} ${grayColour}- Linux${endColour}"
  echo -e "\t${turquoiseColour}2${endColour} ${grayColour}- Windows${endColour}\n"
}

function process_list() {
  machines=$(sed '/\/\*\! For license information please see bundle.js.LICENSE.txt \*\//,/        }(), lf = \[{/d' ${file_name} | grep -vE / | grep -vE \} | awk "/name:/,/resuelta:/" | grep -vE "id:|sku:|skills:" | tr -d ',' | tr -d '"' | sed 's/^ *//')
  echo "${machines}" | sed 's/Fácil/Easy/' | sed 's/Media/Normal/' | sed 's/Difícil/Difficult/' | sed 's/^resuelta: !0 *//' | awk -v RS="" -F'\n' '
    BEGIN { print "Name|IP|OS|Difficult|Skills"; print "----|--|--|---------|----" }
    {
        for (i=1; i<=NF; i++) {
            split($i, a, ": ");
            if (i == 1) name = a[2];
            else if (i == 2) ip = a[2];
            else if (i == 3) so = a[2];
            else if (i == 4) dificultad = a[2];
            else if (i == 5) like = a[2];
        }
        print name "|" ip "|" so "|" dificultad "|" like;
    }
  ' | column -t -s '|'
}

# Execution
trap ctrl_c INT

while getopts "huly:m:i:d:o:s:" arg 2>/dev/null; do
  case $arg in
  h)
    ;;
  u)
    parameter_counter=1
    ;;
  l)
    parameter_counter=2
    ;;
  m)
    parameter_counter=3
    machine_name=$OPTARG
    ;;
  i)
    parameter_counter=3
    ip_address=$OPTARG
    ;;
  d)
    parameter_counter=3
    difficulty=$OPTARG
    ;;
  o)
    parameter_counter=3
    os=$OPTARG
    ;;
  y)
    parameter_counter=4
    machine_name=$OPTARG
    ;;
  *)
    echo -e "\n${redColour}[!] Invalid option${endColour}"
    help_panel
    exit 1
    ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  update
elif [ $parameter_counter -eq 2 ]; then
  list
elif [ $parameter_counter -eq 3 ]; then
  if [ ! "${machine_name}" ] && [ ! "${ip_address}" ] && [ ! "${difficulty}" ] && [ ! "${os}" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}No elements found.${endColour}\n"
  else
    search "${machine_name}" "${ip_address}" "${difficulty}" "${os}"
  fi
elif [ $parameter_counter -eq 4 ]; then
  get_youtube_link "${machine_name}"
else
  help_panel
fi